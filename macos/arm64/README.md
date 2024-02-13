# Linux container image for ARM 64-bit platform and Apple Silicon

[![View in GitHub Container Registry](https://img.shields.io/badge/View%20in-GitHub%20Container%20Registry-blue?logo=github)](https://github.com/workoho/AzAuto-Common-Runbook-FW.Docker/pkgs/container/azauto-common-runbook-fw)

Due to [missing nested virtualzation support for GitHub-hosted macOS runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners/about-larger-runners#limitations-for-macos-larger-runners) and [missing QEMU support for Microsoft .NET framework](https://github.com/PowerShell/PowerShell-Docker/wiki/Known-Issues#arm-and-qemu-not-supported), this image is occasionally build and uploaded manually on a Mac with Apple Silicon using the [build-macos.arm64.sh](https://github.com/Workoho/AzAuto-Common-Runbook-FW.Docker/blob/main/scripts/build-macos.arm64.sh) script.

Due to this, it might not always be up-to-date. If you feel the image shall be updated, you may open a request [here](https://github.com/Workoho/AzAuto-Common-Runbook-FW/issues/new?labels=enhancement&template=feature-request---.md).
