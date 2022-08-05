extends Spatial

func try():
	$TryParticles.emitting = true

func start():
	$DoParticles.emitting = true
	create_tween().tween_property($Magic.material_override, "shader_param/visibility", 1.0, 1.0)
	create_tween().tween_property($Magic, "scale", Vector3.ONE * 2.0, 1.0)
	yield(get_tree().create_timer(1.0),"timeout")
	create_tween().tween_property($Magic.material_override, "shader_param/visibility", 0.0, 1.0)
	create_tween().tween_property($Magic, "scale", Vector3.ONE * 1.0, 1.0)
	$DoParticles.emitting = false
