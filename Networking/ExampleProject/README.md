Godot networking over WebRTC using Nakama as signaling server
=============================================================

Godot's [High-level Multiplayer API](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)
can operate over WebRTC, however, it requires a _signaling server_ to establish
the WebRTC connections between all peers.

[Nakama](https://github.com/heroiclabs/nakama) is an Open Source, scalable game
server that provides many features, including user accounts, authentication,
matchmaking, chat, and [much more](https://heroiclabs.com/).

This Godot add-on provides some utility code to allow easily setting up those
connections using Nakama as the signaling server.

Getting Started
---------------

Read the [full tutorial](https://www.snopekgames.com/tutorial/2021/how-use-webrtc-godot-nakama-signalling-server) on SnopekGames.com.

### TL;DR ###

1. Copy the `addons/`, `webrtc/` and `webrtc_debug/` directories into your project.

2. Add the `Nakama.gd` singleton (in `addons/com.heroiclabs.nakama/`) as an [autoload in Godot](https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html).

3. Add the `OnlineMatch.gd` singleton (in `addons/nakama-webrtc`) as an autoload as well.

Demo and Template
-----------------

This project is a full demo showing how to use this addon, and, in fact, makes
a pretty good template project to start from.

Download the full source code and import into Godot 3.2.3 to run.

Run `docker-compose up -d` in the top-level directory of the code to start a
Nakama instance with the default settings.

In both local and online mode, gamepads are supported, using the XBox A button
to attack. The keyboard controls are WASD for movement and SPACE for attack.

In local mode, you can control player 2 using the arrow keys and ENTER to
attack.

Credits
-------

* Official GDScript Nakama client (Apache License 2.0): https://github.com/heroiclabs/nakama-godot
* GDNative WebRTC plugin (MIT License): https://github.com/godotengine/webrtc-native
* Font used in demo (CC0 1.0 License): https://datagoblin.itch.io/monogram

License
-------

Aside from the pieces listed under Credits above (which each have their own
licenses), everything else in this project is licensed under the MIT License.

