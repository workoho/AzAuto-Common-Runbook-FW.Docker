FROM mcr.microsoft.com/powershell:latest
RUN pwsh \
  -NoLogo \
  -NoProfile \
  -NonInteractive \
  -Command " \
  \$ErrorActionPreference = 'Stop' ; \
  \$ProgressPreference = 'SilentlyContinue' ; \
  Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted ; \
  Install-Module Az -Verbose -MinimumVersion 11.2 -MaximumVersion 11.65535 ; \
  Install-Module Microsoft.Graph -Verbose -MinimumVersion 2.11 -MaximumVersion 2.65535 ; \
  Install-Module Microsoft.Graph.Beta -Verbose -MinimumVersion 2.11 -MaximumVersion 2.65535 ; \
  Install-Module ExchangeOnlineManagement -Verbose -MinimumVersion 3.4 -MaximumVersion 3.65535"
