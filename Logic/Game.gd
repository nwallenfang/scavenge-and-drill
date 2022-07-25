extends Node


var ui: UI

var online_play := true
# debug mode set from command line -> skip cutscenes, main menu, etc.
var debug := false

var own_player: Player
var other_player: Player

var game_started := false



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		ui.toggle_pause()
