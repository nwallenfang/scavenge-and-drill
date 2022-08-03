extends Spatial

var OFF_MATERIAL := preload("res://Assets/Materials/door_light_off.tres")
var ON_MATERIAL := preload("res://Assets/Materials/door_light_on.tres")

var button1_pressed = false
var button2_pressed = false

func open():
	Game.log("open door")

func _on_ButtonPlate1_player_entered(player_id) -> void:
	button1_pressed = true
	$Mesh/Light1.set_surface_material(0, ON_MATERIAL)
	
	if button1_pressed and button2_pressed:
		open()


func _on_ButtonPlate2_player_entered(player_id) -> void:
	button2_pressed = true
	
	$Mesh/Light2.set_surface_material(0, ON_MATERIAL)
	
	if button1_pressed and button2_pressed:
		open()


func _on_ButtonPlate1_player_left(player_id) -> void:
	button1_pressed = false
	$Mesh/Light1.set_surface_material(0, OFF_MATERIAL)


func _on_ButtonPlate2_player_left(player_id) -> void:
	button2_pressed = false
	$Mesh/Light2.set_surface_material(0, OFF_MATERIAL)
	

