extends Camera

var target: Spatial
var offset

export var lerp_speed_without_delta := .999

func initialize(_target: Spatial):
	target = _target
	self.global_transform.origin.x = target.global_transform.origin.x
	offset = self.global_transform.origin - target.global_transform.origin

func _physics_process(delta):
	var new_position = target.global_transform.origin + offset
	self.global_transform.origin = lerp(self.global_transform.origin, new_position, 1.0-pow(1.0-lerp_speed_without_delta, delta))
