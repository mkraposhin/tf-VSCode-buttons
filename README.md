# Visual Studio Code settings for OpenSDN

This repository contains settings for Visual Studio Code IDE to automate build and run of OpenSDN (former Tungsten Fabric) modules.
It includes:

- sample settings.json file to create buttons;
- sample bash scripts to compile OpenSDN binaries and to manipulate them.

[VsCode Action Buttons](https://github.com/seunlanlege/vscode-action-buttons) Visual Studio Code plugin is used to create buttons.

Currently it is assumed that there is only one OpenSDN development project per one user (because actually we have only one tf-dev-sandbox container per one Linux computer).
Therefore, all settings in Visual Studio Code are user-global (are contained in settings.json file).
