# Development Container for Azure Automation Common Runbook Framework

[![View on GitHub Container Registry](https://img.shields.io/badge/View%20in-GitHub%20Container%20Registry-blue?logo=github)](https://ghcr.io/workoho/azauto-common-runbook-fw)
[![Build Docker Image](https://github.com/Workoho/AzAuto-Common-Runbook-FW.Docker/actions/workflows/docker.yml/badge.svg)](https://github.com/Workoho/AzAuto-Common-Runbook-FW.Docker/actions/workflows/docker.yml)
[![Check Upstream](https://github.com/Workoho/AzAuto-Common-Runbook-FW.Docker/actions/workflows/upstreams.yml/badge.svg)](https://github.com/Workoho/AzAuto-Common-Runbook-FW.Docker/actions/workflows/upstreams.yml)

This repository contains the build data for the custom Microsoft PowerShell image provided by the [Azure Automation Common Runbook Framework](https://github.com/Workoho/AzAuto-Common-Runbook-FW) for Azure Automation runbook development.

It is provided with pre-installed PowerShell modules that enable faster startup of development containers. The image is compatible for x64 and ARM64 architectures, including Apple Silicon Macs.

## How To Use

Ready-to-use images can be retrieved from the [GitHub Container Registry](https://ghcr.io/workoho/azauto-common-runbook-fw).

**We recommend you start with our [project template](https://github.com/Workoho/AzAuto-Project.tmpl) which comes with a pre-configured development container and Visual Studio Code setup.** Using free GitHub Codespaces, you may even start directly in your browser:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Workoho/AzAuto-Project.tmpl)

### Included PowerShell modules

- [Az](https://learn.microsoft.com/en-us/powershell/azure/new-azureps-module-az) - Latest Major Version 11.x
- [Microsoft.Graph](https://learn.microsoft.com/en-us/powershell/microsoftgraph/?view=graph-powershell-1.0) - Latest Major Version 2.x
- [Microsoft.Graph.Beta](https://learn.microsoft.com/en-us/powershell/microsoftgraph/?view=graph-powershell-beta) - Latest Major Version 2.x
- [ExchangeOnlineManagement](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell) - Latest Major Version 3.x
- [PnP.PowerShell](https://pnp.github.io/powershell/) - Latest Major Version 2.x

## How To Update

Every night[^1] the image is updated to ensure that it is always up to date with the latest production versions of the Microsoft/Debian base image as well as the included PowerShell modules.

The development container is designed so that it can be rebuilt at any time without losing your data. To update to the latest versions, you can simply trigger a rebuild, e.g. by rebuilding your GitHub Codespace or your local development container.



[^1]: Except for ARM64 / Apple Silicon variant. See [macos/arm64/README.md](https://github.com/Workoho/AzAuto-Common-Runbook-FW.Docker/blob/main/macos/arm64/README.md).
