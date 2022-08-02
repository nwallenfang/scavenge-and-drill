extends Spatial
class_name MouseDetectionLayer

var current_mouse_position: Vector3
var position_has_been_calculated_this_frame := false

func get_plane() -> Plane:
	return Plane($Origin.global_transform.origin, $xDirection.global_transform.origin, $zDirection.global_transform.origin)

func get_global_layer_mouse_position() -> Vector3:
	if not position_has_been_calculated_this_frame:
		current_mouse_position = calculate_mouse_position()
		position_has_been_calculated_this_frame = true
	return current_mouse_position

func calculate_mouse_position() -> Vector3:
	var camera = Game.main_cam
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = camera.project_ray_normal(get_viewport().get_mouse_position())
	return get_plane().intersects_ray(from, to)

func _ready():
	Game.mouse_layer = self

func _physics_process(delta):
	position_has_been_calculated_this_frame = false
