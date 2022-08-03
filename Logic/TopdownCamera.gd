extends Camera

var target: Spatial
var target2: Spatial
export var offset : Vector3


export var zoom_start := 3.0
export var zoom_end := 5.0
export var zoom_min := 1.2
export var zoom_max := 1.8

export var lerp_speed_without_delta := .999

func _ready() -> void:
	self.set_physics_process(false)

func clamp_and_map(value, istart, istop, ostart, ostop) -> float:
	value = clamp(value, istart, istop)
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))


func initialize(_target: Spatial, _target2 = null):
	offset = global_translation
	target = _target
	target2 = _target2
	self.set_physics_process(true)

#func initialize2(_target, _target2):
#	target = _target
#	target2 = _target2
#	self.set_physics_process(true)

func _physics_process(delta):
	if target2 != null:
		var mixed_position = (target.global_translation + target2.global_translation) / 2.0
		var dist := target.global_translation.distance_to(target2.global_translation)
		var zoom := clamp_and_map(dist, zoom_start, zoom_end, zoom_min, zoom_max)
		var new_position = mixed_position + zoom * offset
		self.global_transform.origin = lerp(self.global_transform.origin, new_position, 1.0-pow(1.0-lerp_speed_without_delta, delta))
	elif target != null:
		var new_position = target.global_transform.origin + offset
		self.global_transform.origin = lerp(self.global_transform.origin, new_position, 1.0-pow(1.0-lerp_speed_without_delta, delta))
