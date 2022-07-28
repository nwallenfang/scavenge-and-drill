extends Node


onready var ui: UI = get_node("/root/Main/Level/UI")

var online_play := true
# debug mode set from command line -> skip cutscenes, main menu, etc.
var debug := false

var own_player: Player
var other_player: Player

var game_started := false

var viewport_sprite: Sprite
var main_cam: Camera

func _process(delta: float) -> void:
	if is_instance_valid(viewport_sprite) and is_instance_valid(main_cam):
		if viewport_sprite != null:
			#print(viewport_sprite.material.get("shader_param/ViewportTexture2"))
			viewport_sprite.material.set_shader_param("sideview_active", main_cam.shader_active)
			viewport_sprite.material.set_shader_param("sideview_visible", main_cam.shader_visible)
			viewport_sprite.material.set_shader_param("sideview_direction", main_cam.shader_direction)
	if Input.is_action_just_pressed("pause"):
		ui.toggle_pause()


func log(msg: String):
	if ui == null:
		return
	ui.add_to_log(msg)
