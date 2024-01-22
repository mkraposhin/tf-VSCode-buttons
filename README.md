# Visual Studio Code settings for OpenSDN

This repository contains settings for Visual Studio Code IDE to automate build and run of OpenSDN (former Tungsten Fabric) modules.
It includes:

- sample settings.json file to create buttons;
- sample bash scripts to compile OpenSDN binaries and to manipulate them.

[VsCode Action Buttons](https://github.com/seunlanlege/vscode-action-buttons) Visual Studio Code plugin by [Seun LanLege](https://github.com/seunlanlege) is used to create buttons.

Currently it is assumed that:

1. there is only one OpenSDN development project per one user (because actually we have only one tf-dev-sandbox container per one Linux computer);
2. therefore, all settings in Visual Studio Code are user-global (are contained in settings.json file);
3. Visual Studio Code has been started in the OpenSDN development project directory (where folders contrail/, output/, tf-dev-env/ reside);
4. scripts (opensdn_sync_build.sh, run_gdb_server.sh, etc) reside in the OpenSDN development project director.


