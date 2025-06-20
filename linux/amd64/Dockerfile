FROM mcr.microsoft.com/powershell:debian-12

LABEL org.opencontainers.image.title="Azure Automation Common Runbook Framework" \
      org.opencontainers.image.url="https://github.com/workoho/AzAuto-Common-Runbook-FW" \
      org.opencontainers.image.documentation="https://github.com/workoho/AzAuto-Common-Runbook-FW/wiki" \
      org.opencontainers.image.authors="Workoho GmbH" \
      org.opencontainers.image.vendor="Workoho GmbH" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.description="This custom PowerShell image is provided with pre-installed PowerShell modules as well as Azure CLI and Bicep CLI that enable faster startup of development containers. It is based on the latest official PowerShell image from Microsoft, which in turn is based on Debian 12 (Bookworm)."

ARG MODULES='Az,Microsoft.Graph,Microsoft.Graph.Beta,Microsoft.Graph.Entra,Microsoft.Graph.Entra.Beta,ExchangeOnlineManagement,MicrosoftTeams,PnP.PowerShell'
ENV MODULES=${MODULES}

ARG MODULE_VERSIONS='14.0:14.65535,2.0:2.65535,2.0:2.65535,0.0-preview:1.65535,0.0-preview:1.65535,3.0:3.65535,6.0:6.65535,2.0:2.65535'
ENV MODULE_VERSIONS=${MODULE_VERSIONS}

RUN --mount=type=cache,target=/var/lib/apt \
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
    && az extension add --allow-preview true --name resource-graph \
    && az extension add --allow-preview true --name storage-preview \
    && export POWERSHELL_TELEMETRY_OPTOUT=1 \
    && pwsh \
      -NoLogo \
      -NoProfile \
      -NonInteractive \
      -ExecutionPolicy Bypass \
      -Command " \
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted; \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        \$modules = \$env:MODULES -split ',' ; \
        \$module_versions = \$env:MODULE_VERSIONS -split ',' ; \
        for (\$i = 0; \$i -lt \$modules.Length; \$i++) { \
          \$module = \$modules[\$i] ; \
          \$version = \$module_versions[\$i] ; \
          \$params = @{ Name = \$module ; Scope = 'AllUsers' ; AllowClobber = \$true ; Force = \$true ; Verbose = \$true } ; \
          if (\$version -match '^(?:(\d+(?:\.\d+)*)(?:-(.+))?|\*):(?:(\d+(?:\.\d+)*)(?:-(.+))?|\*)\$') { \
            if (\$Matches[1] -and \$Matches[1] -ne '*') { \$params.MinimumVersion = \$Matches[1] } ; \
            if (\$Matches[2]) { \$params.AllowPrerelease = \$true } ; \
            if (\$Matches[3] -and \$Matches[4] -ne '*') { \$params.MaximumVersion = \$Matches[4] } ; \
            if (\$Matches[4]) { \$params.AllowPrerelease = \$true } ; \
          } elseif (\$version -match '^(\d+(?:\.\d+)*)(?:-(.+))?\$') { \
            \$params.RequiredVersion = \$Matches[0] ; \
            if (\$Matches[2]) { \$params.AllowPrerelease = \$true } ; \
          } else { \
            Write-Error 'Invalid version format for module \$module' ; \
            exit 1 ; \
          } \
          Install-Module @params ; \
        }" \
        # Clean up
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
