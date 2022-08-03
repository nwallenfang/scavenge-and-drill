extends Spatial

enum STATES {IDLE, PATH, ATTACK}
var state
var path: Path
var path_target_position : Vector3
var path_direction := 1
var path_speed := 1.5
var current_path_offset := 0.0
var hp := 3
var can_attack := false
var attack_speed := 2.5
var target: Spatial
var damage := 30.0

func _physics_process(delta: float):
	var last_pos := global_translation
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
		STATES.ATTACK:
			if target != null:
				var direction := target.global_translation - global_translation
				direction.y = 0.0
				direction = direction.normalized()
				global_translation = global_translation + direction * delta * attack_speed
	var target_y_rotation = - (Vector2(global_translation.x, global_translation.z) - Vector2(last_pos.x, last_pos.z)).angle()
	rotation.y = lerp_angle(rotation.y, target_y_rotation, .2)

func _network_process(delta):
	if Game.host:
		rpc_unreliable("safe_sync_position", global_translation)

remotesync func set_state(s, target_name = ""):
	state = s
	if target_name != "":
		if "1" in target_name:
			target = Game.roller
		else:
			target = Game.drill

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

func _on_PlayerDetection_area_entered(area):
	var target_name = area.get_parent().name
	if Game.host and can_attack:
		rpc("set_state", STATES.ATTACK, target_name)


func _on_Hitbox_area_entered(area):
	if Game.host:
		rpc("hit_player")

remotesync func hit_player():
	Game.power -= damage
	queue_free()
