extends Camera

export var sideview_activated = false

var target: Spatial
var partner
var offset

var own_target_pos: Vector3
var group_target: Vector3
var target_weight := 0.0

var active := false

var shader_direction:= Vector2.RIGHT
var shader_active := 0.0
var shader_visible := 0.0

export var boss := false
export var bind_distance := 7.0
export var full_active_extra_distance := 2.0
export var lerp_speed_without_delta := .9995

func initialize(_target: Spatial, _partner):
	target = _target
	partner = _partner
	self.global_transform.origin.x = target.global_transform.origin.x
	offset = self.global_transform.origin - target.global_transform.origin
	active = true

func get_viewport_angle_to_pos(pos):
	var x_notify_middle : float = .5
	var y_notify_middle : float = .5
	var notify_middle := Vector2(x_notify_middle, y_notify_middle)
	var unproj_pos = self.unproject_position(pos)
	unproj_pos.x /= get_viewport().size.x
	unproj_pos.y /= get_viewport().size.y
	var flip_because_behind = self.is_position_behind(pos) and unproj_pos.y < 0
	var angle = -(unproj_pos - notify_middle).angle_to(Vector2.DOWN if flip_because_behind else Vector2.UP)
	return angle

var sideview_avtive
func set_sideview_active(a):
	if a == sideview_avtive:
		return
	sideview_avtive = a
	$Tween.stop_all()
	$Tween.remove_all()
	if sideview_avtive:
		$Tween.interpolate_property(self, "shader_active", 1.0, 0.0, 1.0, Tween.TRANS_CUBIC , Tween.EASE_IN)
		$Tween.interpolate_property(self, "shader_visible", 1.0, 0.0, .6)
		$Tween.interpolate_property(self, "target_weight", 1.0, 0.0, 1.0)
		$Tween.start()
	else:
		#$Tween.interpolate_property(self, "shader_active", shader_active, 1.0, 1.0)
		$Tween.interpolate_property(self, "shader_visible", 0.0, 1.0, .3)
		$Tween.interpolate_property(self, "target_weight", 0.0, 1.0, 1.0)
		$Tween.start()

func _physics_process(delta):
	if not active:
		return
	own_target_pos = target.global_transform.origin + offset
	var distance_to_partner := own_target_pos.distance_to(partner.own_target_pos)
	group_target = lerp(own_target_pos, partner.own_target_pos, 0.0 if boss else 1.0)
	if distance_to_partner < bind_distance:
		set_sideview_active(false)
		#shader_visible = lerp(shader_visible, 1.0, 1.0-pow(1.0-.995, delta))
	else:
		set_sideview_active(true)
		shader_direction = Vector2.UP.rotated(get_viewport_angle_to_pos(partner.own_target_pos))
		#var extra_distance = max(distance_to_partner - bind_distance, 0.0)
		#shader_active = 1.0 - min(extra_distance / full_active_extra_distance, 1.0)
		#shader_visible = lerp(shader_visible, 0.0, 1.0-pow(1.0-.995, delta))
	var target_pos = lerp(own_target_pos, group_target, target_weight)
	self.global_transform.origin = lerp(self.global_transform.origin, target_pos, 1.0-pow(1.0-lerp_speed_without_delta, delta))
