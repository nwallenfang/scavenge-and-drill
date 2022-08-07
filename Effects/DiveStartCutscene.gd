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
	if not is_instance_valid(point_1):
		return
	if Game.game_started:
		camera_offset = x
		$TreasureCam.global_transform = get_interpolated_transform(x)


export var hook_high : float = 28.0
export var hook_low : float = 0.8

export var hook_offset : float setget set_hook_offset
func set_hook_offset(x):
	if Game.game_started and is_instance_valid($HookModel):
		hook_offset = x
		if Game.try_count == 1:
			$HookModel.global_translation.y = lerp(hook_low, 40.0, x)
		else:
			$HookModel.global_translation.y = lerp(hook_low, hook_high, x)

var cutscene_active := false

func start_cutscene():
	cutscene_active = true
	Game.ui.get_node("SpaceToSkip").visible = true
	point_1 = $Point1
	point_2 = $Point2
	point_3 = $Point3
	self.visible = true
	if Game.try_count == 1:
		$AnimationPlayer.play("CutsceneLong")
	else:
		$AnimationPlayer.play("Cutscene")

signal cutscene_ended

remotesync func skip_cutscene():
	stop_intro_music()
	$AnimationPlayer.stop()
	end_cutscene()

func host_sync_end_cutscene():
	if Game.host and cutscene_active:
		rpc("end_cutscene")

func stop_intro_music():
	pass

func trigger_dialog():
	Dialog.trigger("intro_sequence")

remotesync func end_cutscene():
	Game.ui.get_node("SpaceToSkip").visible = false
	emit_signal("cutscene_ended")
	cutscene_active = false
	yield(get_tree().create_timer(0.5), "timeout")
	self.visible = false

func _input(event):
	if cutscene_active and event is InputEventKey:
		if event.is_action_pressed("skip_dialog"):
			rpc("skip_cutscene")

var volume := 4.0
func play_chain_sound():
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($ChainSound, "volume_db", volume, 0.2).set_ease(Tween.EASE_IN)
	$ChainSound.play()


func stop_chain_sound():
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($ChainSound, "volume_db", -80.0, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_callback($ChainSound, "stop")
