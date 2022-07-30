extends RigidBody

func set_length(l):
	$C.scale = Vector3.ONE * l / 2.0
	$C.translation.z = - l / 2.0
