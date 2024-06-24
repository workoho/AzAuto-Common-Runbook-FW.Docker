# Based on: https://github.com/PowerShell/PowerShell-Docker/blob/master/release/7-4/debian12/docker/Dockerfile
# Copyright (c) Microsoft Corporation & Workoho GmbH
# Licensed under the MIT License.

FROM arm64v8/debian:bookworm AS installer-env

RUN --mount=type=cache,target=/var/lib/apt \
    --mount=type=cache,target=/var/cache/apt \
    DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends -y \
    # curl is required to grab the Linux package
        curl \
        tar \
        gnupg \
    # required for SSL
        ca-certificates \
    # Download the Linux package and save it
    && PS_PACKAGE_URL=$(curl -sSL https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep 'browser_' | cut -d\" -f4 | grep 'linux-arm64.tar.gz') \
    && echo ${PS_PACKAGE_URL} \
    && curl -sSL ${PS_PACKAGE_URL} -o /tmp/powershell.tar.gz

# Install the tar.gz file in this image and make powershell available
FROM arm64v8/debian:bookworm AS final-image

LABEL org.opencontainers.image.title="Azure Automation Common Runbook Framework" \
      org.opencontainers.image.url="https://github.com/workoho/AzAuto-Common-Runbook-FW" \
      org.opencontainers.image.documentation="https://github.com/workoho/AzAuto-Common-Runbook-FW/wiki" \
      org.opencontainers.image.authors="Workoho GmbH" \
      org.opencontainers.image.vendor="Workoho GmbH" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.description="This custom PowerShell image is provided with pre-installed PowerShell modules as well as Azure CLI and Bicep CLI that enable faster startup of development containers. It is based on Debian 12 (Bookworm) to run on ARM-based devices, including Apple Silicon Macs, and installs the latest PowerShell version as long as Microsoft does not provide an official ARM64 image."

ARG MODULES='Az,Microsoft.Graph,Microsoft.Graph.Beta,ExchangeOnlineManagement,MicrosoftTeams,PnP.PowerShell'
ENV MODULES=${MODULES}

ARG MODULE_VERSIONS='12.0:12.65535,2.0:2.65535,2.0:2.65535,3.0:3.65535,6.0:6.65535,2.0:2.65535'
ENV MODULE_VERSIONS=${MODULE_VERSIONS}

# Define ENVs for Localization/Globalization
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PS_INSTALL_FOLDER=/opt/microsoft/powershell/7 \
    # set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache \
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-Debian-12

# Install dependencies and clean up
RUN --mount=from=installer-env,target=/mnt/pwsh,source=/tmp \
    --mount=type=cache,target=/var/lib/apt \
    --mount=type=cache,target=/var/cache/apt \
    DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends -y \
    # less is required for help in powershell
        less \
    # required to setup the locale
        locales \
    # required for SSL
        ca-certificates \
        gss-ntlmssp \
        libicu72 \
        libssl3 \
        libc6 \
        libgcc-s1 \
        libgssapi-krb5-2 \
        liblttng-ust1 \
        libstdc++6 \
        zlib1g \
    # PowerShell remoting over SSH dependencies
        openssh-client \
    # Azure CLI dependencies
        curl \
    && apt-get dist-upgrade -y \
    && locale-gen $LANG && update-locale \
    # Install Azure CLI
    && curl -sSL https://aka.ms/InstallAzureCLIDeb | bash \
    && az bicep install \
    # Install Azure CLI extensions
    && az extension add --allow-preview true --name azure-devops \
    && az extension add --allow-preview true --name interactive \
    && az extension add --allow-preview true --name azure-cli-ml \
    && az extension add --allow-preview true --name resource-graph \
    && az extension add --allow-preview true --name storage-preview \
    && export POWERSHELL_TELEMETRY_OPTOUT=1 \
    # Create PowerShell folder
    && mkdir -p ${PS_INSTALL_FOLDER} \
    # Extract powershell to the folder
    && tar -xvf /mnt/pwsh/powershell.tar.gz -C ${PS_INSTALL_FOLDER} \
    # Give all user execute permissions and remove write permissions for others
    && chmod a+x,o-w ${PS_INSTALL_FOLDER}/pwsh \
    # Create the pwsh symbolic link that points to powershell
    && ln -sf ${PS_INSTALL_FOLDER}/pwsh /usr/bin/pwsh \
    # Create the pwsh-preview symbolic link that points to powershell
    && ln -sf ${PS_INSTALL_FOLDER}/pwsh /usr/bin/pwsh-preview \
    && pwsh \
        -NoLogo \
        -NoProfile \
        -NonInteractive \
        -Command " \
          \$ErrorActionPreference = 'Stop' ; \
          \$ProgressPreference = 'SilentlyContinue' ; \
          while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
          } \
          Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted; \
          \$modules = \$env:MODULES -split ',' ; \
          \$module_versions = \$env:MODULE_VERSIONS -split ',' ; \
          for (\$i = 0; \$i -lt \$modules.Length; \$i++) { \
            \$module = \$modules[\$i] ; \
            \$version = \$module_versions[\$i] ; \
            if (\$version -eq 'latest') { \
              Install-Module \$module -Scope AllUsers -AllowClobber -Force -Verbose ; \
              continue ; \
            } elseif (\$version -match '^\d+(\.\d+)*:\d+(\.\d+)*$') { \
              Install-Module \$module -Scope AllUsers -AllowClobber -Force -Verbose -MinimumVersion \$version.Split(':')[0] -MaximumVersion \$version.Split(':')[1] ; \
              continue ; \
            } elseif (\$version -match '^\d+(\.\d+)*$') { \
              Install-Module \$module -Scope AllUsers -AllowClobber -Force -Verbose -RequiredVersion \$version ; \
              continue ; \
            } else { \
              Write-Error 'Invalid version format for module \$module' ; \
              exit 1 ; \
            } \
          }" \
          # Clean up
          && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use PowerShell as the default shell
# Use array to avoid Docker prepending /bin/sh -c
CMD [ "pwsh" ]
