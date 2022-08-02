extends Spatial

enum STATES {IDLE, PATH}
var state
var path: Path
var path_target_position : Vector3
var path_direction := 1
var path_speed := 2.0
var current_path_offset := 0.0
var hp := 3

func _physics_process(delta: float):
	match state:
		STATES.IDLE:
			pass
		STATES.PATH:
			var next_offset := clamp(current_path_offset + (delta * path_direction * path_speed) / path.curve.get_baked_length(), 0.0, 1.0)
			var pos := path.curve.interpolate_baked(next_offset * path.curve.get_baked_length())
			global_translation = pos
			current_path_offset = next_offset
			if next_offset == 1.0 or next_offset == 0.0:
				path_direction = -path_direction

func _network_process(delta):
	if Game.host:
		rpc_unreliable("safe_sync_position", global_translation)

var sync_dist := .1
remote func safe_sync_position(pos):
	var dist := global_translation.distance_to(pos)
	if dist > sync_dist:
		Game.log("Fish pos SYNC was necesarry (%f distance)" % dist)
		global_translation = pos


func _on_Hurtbox_area_entered(area):
	if Game.host:
		rpc("on_getting_hit")

remotesync func on_getting_hit():
	hp -= 3 if Game.upgrades.more_bullet_damage else 1
	if hp == 0:
		queue_free()
