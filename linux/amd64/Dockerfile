LABEL org.opencontainers.image.title="Azure Automation Common Runbook Framework" \
      org.opencontainers.image.url="https://github.com/Workoho/AzAuto-Common-Runbook-FW" \
      org.opencontainers.image.documentation="https://github.com/Workoho/AzAuto-Common-Runbook-FW/wiki" \
      org.opencontainers.image.authors="Workoho GmbH" \
      org.opencontainers.image.vendor="Workoho GmbH" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.description="This custom Microsoft PowerShell image is provided with pre-installed PowerShell modules that enable a faster start of development containers."

FROM mcr.microsoft.com/powershell:debian-12

ARG MODULES='Az,Microsoft.Graph,Microsoft.Graph.Beta,ExchangeOnlineManagement,PnP.PowerShell'
ENV MODULES=${MODULES}

ARG MODULE_VERSIONS='11.3:11.65535,2.13:2.65535,2.13:2.65535,3.4:3.65535,2.3:2.65535'
ENV MODULE_VERSIONS=${MODULE_VERSIONS}

RUN export POWERSHELL_TELEMETRY_OPTOUT=1 \
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
    }"
