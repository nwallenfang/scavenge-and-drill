extends GroundedPhysicsMover3D

var facing_direction := Vector3.RIGHT

var controlled := false

var puppet_position: Vector3

func _physics_process(delta):
	if not Game.game_started:
		return
	if controlled:
		var move_direction := Vector3.ZERO
		move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		move_direction.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

		var move_direction_normalized := move_direction.normalized()
		if move_direction.length() > .1:
			facing_direction = move_direction_normalized

		add_acceleration(ACC * move_direction_normalized)
		execute_movement(delta)
		
		rpc("set_puppet_position", global_transform.origin)
	else:
		global_transform.origin = puppet_position

puppet func set_puppet_position(pos):
	puppet_position = pos
