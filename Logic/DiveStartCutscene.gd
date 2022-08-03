extends Spatial

var point_1 : Spatial
var point_2 : Spatial
var point_3 : Spatial

func _ready():
	point_1 = $Point1
	point_2 = $Point2
	point_3 = $Point3

func transform_lerp(a:Transform,b:Transform,x:float):
	var base := a.basis.slerp(b.basis, x)
	var origin = lerp(a.origin, b.origin, x)
	return Transform(base, origin)

func get_interpolated_transform(x: float):
	if x <= 1.0:
		return point_1.global_transform
	elif x > 1.0 and x <= 2.0:
		return transform_lerp(point_1.global_transform, point_2.global_transform, x - 1.0)
	elif x > 2.0 and x <= 3.0:
		return transform_lerp(point_2.global_transform, point_3.global_transform, x - 2.0)
	else:
		return point_3.global_transform

export var camera_offset : float setget set_camera_offset
func set_camera_offset(x):
	if Game.game_started:
		camera_offset = x
		$TreasureCam.global_transform = get_interpolated_transform(x)


export var hook_high : float = 26.0
export var hook_low : float = 2.0

export var hook_offset : float setget set_hook_offset
func set_hook_offset(x):
	if Game.game_started:
		hook_offset = x
		$HookModel.global_translation.y = lerp(hook_low, hook_high, x)

func start_cutscene():
	point_1 = $Point1
	point_2 = $Point2
	point_3 = $Point3
	self.visible = true
	$AnimationPlayer.play("Cutscene")

signal cutscene_ended

func end_cutscene():
	self.visible = false
	emit_signal("cutscene_ended")
