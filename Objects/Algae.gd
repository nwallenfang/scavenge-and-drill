extends Spatial

export var trigger_distance := 2.0
func _physics_process(delta):
	if not $Area.get_overlapping_bodies().empty():
		var push = Vector2.ZERO
		for b in $Area.get_overlapping_bodies():
			var direction = b.global_translation.direction_to(self.global_translation)
			var direction_2d = Vector2(direction.x, direction.z).normalized()
			var self_pos_2d = Vector2(self.global_translation.x, self.global_translation.z)
			var b_pos_2d = Vector2(b.global_translation.x, b.global_translation.z)
			var dist = self_pos_2d.distance_to(b_pos_2d)
			#print(dist)
			var push_trigger = 1.0 - clamp(dist / trigger_distance, 0.0, 1.0)
			var push_vector = push_trigger * direction_2d
			push += push_vector
		var push_direction = push.normalized()
		var push_strength = min(1.0,push.length())
		print(push_direction)
		print(push_strength)
		$Model/Mesh.get("material/0").set("shader_param/push_direction", push_direction)
		$Model/Mesh.get("material/0").set("shader_param/push_strength", push_strength)
		
