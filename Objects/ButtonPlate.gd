extends Spatial

var is_pressed = false


signal player_entered(id)
signal player_left(id)

func _ready() -> void:
	Game.log(str(get_network_master()))

remotesync func player_area_enter(id):
	if is_pressed:
		# for example when Player1 is pressing down and Player2 enters as well
		return
	Game.log(str(id) + " entered plate a" + name)
	
	emit_signal("player_entered", id)
	is_pressed = true
	$EnterSound.play()

remotesync func player_area_leave(id):
	if not is_pressed:
		return
	Game.log(str(id) + " left plate " + name)
	
	emit_signal("player_left", id)
	is_pressed = false
	$LeaveSound.play()


func _on_PressArea_body_entered(body: Node) -> void:
	if body is Player:
#		emit_signal()
		rpc("player_area_enter", get_tree().get_network_unique_id())


func _on_PressArea_body_exited(body: Node) -> void:
	print("leave")
	if body is Player:
		rpc("player_area_leave", get_tree().get_network_unique_id())
