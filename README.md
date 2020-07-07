# About

Base structure for my games forked from [](https://github.com/deepnight/gameBase).
The language is **Haxe** ([](https://haxe.org)).
Builds are done with **Hashlink** ([](https://hashlink.haxe.org)), a virtual machine, working on all platforms. 
And using **Heaps** ([](https://heaps.io)), a 2D/3D Haxe library (ie. an Haxelib). All of those tools are free and open-source.

# Installation & usage

- First you can follow points 1 to 5 of this tutorial from *Sébastien Bénard* : https://deepnight.net/tutorial/a-quick-guide-to-installing-haxe/
- Download it into your local repository or fork this project then clone yours 
- Open the root folder with vscode
- Press F5 to launch the game in debug

## Tools and optionnal setup

- Visual Studio Code Command bar (id: gsppvo.vscode-commandbar) is recommended.
[[screens/commandBar.jpg|alt=commandbar]]

  - // TODO: Add command bar screen

## Norms

We are using the UpperCamelCase for file and class names. This means all worlds are next to each other without space and must start with an uppercase. `-` are allowed for different file versions (eg. Robot.png and Robot-Blue.png or Robot-Normal.png).
Folders must be in lowerCamelCase (same but the first word has no starting uppercase) as well as variables and functions.

# Common Questions

## Exporting a new font

https://community.heaps.io/t/creating-bitmap-fonts-not-working-for-me/382/5

# Other ressources

- [CastleDB](http://castledb.org/) for the game database