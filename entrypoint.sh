#!/bin/bash

# Check if the platform is not amd64
if [ "$(uname -m)" != "x86_64" ]; then
  # Install PowerShell modules
  pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    \$modules = \$env:MODULES -split ','
    \$module_versions = \$env:MODULE_VERSIONS -split ','
    for (\$i = 0; \$i -lt \$modules.Length; \$i++) {
      \$module = \$modules[\$i]
      \$version = \$module_versions[\$i]
      if (\$version -eq 'latest') {
        Install-Module \$module -Scope AllUsers -AllowClobber -Force -Verbose
      } elseif (\$version -match '^\d+(\.\d+)*:\d+(\.\d+)*$') {
        Install-Module \$module -Scope AllUsers -AllowClobber -Force -Verbose -MinimumVersion \$version.Split(':')[0] -MaximumVersion \$version.Split(':')[1]
      } elseif (\$version -match '^\d+(\.\d+)*$') {
        Install-Module \$module -Scope AllUsers -AllowClobber -Force -Verbose -RequiredVersion \$version
      } else {
        Write-Error 'Invalid version format for module \$module'
      }
    }
  "
fi

# If arguments were passed, execute them
if [ "$#" -gt 0 ]; then
  exec "$@"
else
  # Execute the default command
  exec pwsh
fi
