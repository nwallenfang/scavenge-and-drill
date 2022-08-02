extends Player

var aim_direction : Vector2

func _physics_process(delta):
	._physics_process(delta)
	if controlled:
		var global_mouse_pos := Game.mouse_layer.get_global_layer_mouse_position()
		var direction := Vector2(global_translation.x, global_translation.z).direction_to(Vector2(global_mouse_pos.x, global_mouse_pos.z))
		$Model/Head.rotation.y = -direction.angle() + PI/2.0
		aim_direction = direction
		if Input.is_action_just_pressed("shoot"):
			Network.rpc("spawn_object", "bullet", $Model/Head/BulletSpawn.global_translation, {"direction": aim_direction})

func _network_process(delta):
	if controlled:
		rpc_unreliable("set_puppet_aim", aim_direction)

remote func set_puppet_aim(aim_direction):
	pass
