extends Node

var online_play := true
# debug mode set from command line -> skip cutscenes, main menu, etc.
var debug := false

var own_player: Player
var other_player: Player

var game_started := false
