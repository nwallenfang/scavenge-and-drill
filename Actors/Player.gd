extends GroundedPhysicsMover3D

var facing_direction := Vector3.RIGHT

func _physics_process(delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

	var move_direction_normalized := move_direction.normalized()
	if move_direction.length() > .1:
		facing_direction = move_direction_normalized

	add_acceleration(ACC * move_direction_normalized)
	execute_movement(delta)
