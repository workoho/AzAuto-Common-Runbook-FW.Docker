# entrypoint.ps1
param()

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$modules = $env:MODULES -split ','
$module_versions = $env:MODULE_VERSIONS -split ','

function Install-ModuleVersion($module, $version) {
    $params = @{
        Name         = $module
        Scope        = 'CurrentUser'
        AllowClobber = $true
        Force        = $true
        Verbose      = $true
    }

    switch -Regex ($version) {
        'latest' {
            Install-Module @params
        }
        '^\d+(\.\d+)*:\d+(\.\d+)*$' {
            $params['MinimumVersion'] = $version.Split(':')[0]
            $params['MaximumVersion'] = $version.Split(':')[1]
            Install-Module @params
        }
        '^\d+(\.\d+)*$' {
            $params['RequiredVersion'] = $version
            Install-Module @params
        }
        default {
            Write-Error "Invalid version format for module $module"
            exit 1
        }
    }
}

for ($i = 0; $i -lt $modules.Length; $i++) {
    Install-ModuleVersion -module $modules[$i] -version $module_versions[$i]
}
