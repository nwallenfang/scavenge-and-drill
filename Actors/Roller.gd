extends Player

export var move_acc_default := 30.0
export var move_acc_upgraded := 40.0

var aim_direction : Vector2

func _physics_process(delta):
	._physics_process(delta)
	if controlled:
		var global_mouse_pos := Game.mouse_layer.get_global_layer_mouse_position()
		if global_mouse_pos == null:
			global_mouse_pos = Vector3(0.0, 0.0, 0.0)
		var direction := Vector2(global_translation.x, global_translation.z).direction_to(Vector2(global_mouse_pos.x, global_mouse_pos.z))
		$Model/Head.rotation.y = -direction.angle() + PI/2.0
		aim_direction = direction
		if Input.is_action_just_pressed("shoot"):
			Network.rpc("spawn_object", "bullet", $Model/Head/BulletSpawn.global_translation, {"direction": aim_direction})
		if Input.is_action_just_pressed("initiate_swap"):
			Game.rpc("try_swap",name)

func _network_process(delta):
	._network_process(delta)
	if controlled:
		rpc_unreliable("set_puppet_aim", aim_direction)

remote func set_puppet_aim(aim_direction_set):
	self.aim_direction = aim_direction_set
	$Model/Head.rotation.y = -aim_direction.angle() + PI/2.0
