extends Spatial

export var trigger_distance := 1.4
export var max_strength := .8

var shader_push_direction_not_normalized : Vector2 = Vector2.ZERO
var shader_push_strength : float = 0.0
export var push_speed_up := 10.0
export var push_speed_down := 1.0
export var push_speed_turn := 10.0
func _physics_process(delta):
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
	var push_direction : Vector2 = push
	var push_strength = clamp(push.length(), 0.0, max_strength)
	
	if push_direction.length() > 0.0:
		shader_push_direction_not_normalized = shader_push_direction_not_normalized.move_toward(push_direction, delta * push_speed_down)
	if push_strength > shader_push_strength:
		shader_push_strength = min(push_strength, shader_push_strength + delta * push_speed_up)
	else:
		shader_push_strength = max(push_strength, shader_push_strength - delta * push_speed_down)
#		print(push_direction)
#		print(push_strength)
	$Model/Mesh.get("material/0").set("shader_param/push_direction", shader_push_direction_not_normalized.normalized())
	$Model/Mesh.get("material/0").set("shader_param/push_strength", shader_push_strength)
		
