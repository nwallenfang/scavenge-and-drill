extends GroundedPhysicsMover3D
class_name Player

var facing_direction := Vector3.RIGHT

var controlled := false

var puppet_position: Vector3

var current_hover_object: Spatial

#var inventory_ball_count := 0

var cable_force := Vector3.ZERO
var cable_factor := 1.0

var static_mode := false



func _physics_process(delta):
	if not Game.game_started:
		return
	if controlled:
		if static_mode:
			return
		var move_direction := Vector3.ZERO
		move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		move_direction.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

		var move_direction_normalized := move_direction.normalized()
		if move_direction.length() > .1:
			facing_direction = move_direction_normalized

		add_acceleration(ACC * move_direction_normalized)
		if cable_force.length() > .02:
			add_acceleration(ACC * cable_force * cable_factor)
		execute_movement(delta)
		
		var target_hover_object = null
		var best_distance := 100.0
		for hover_area in $InteractDetection.get_overlapping_areas():
			var hover_object = hover_area.get_parent()# as InteractObject
			if hover_object.limit_to_player != 0 and not str(hover_object.limit_to_player) in self.name:
				continue
			var dist = self.global_transform.origin.distance_to(hover_object.global_transform.origin)
			if dist < best_distance:
				best_distance = dist
				target_hover_object = hover_object
		if target_hover_object != null:
			if target_hover_object != current_hover_object:
				if is_instance_valid(current_hover_object):
					current_hover_object.set_hover_state(false, self.name)
				target_hover_object.set_hover_state(true, self.name)
				current_hover_object = target_hover_object
		else:
			if is_instance_valid(current_hover_object):
				current_hover_object.set_hover_state(false, self.name)
				current_hover_object = null
		if Input.is_action_just_pressed("interact"):
			if is_instance_valid(current_hover_object):
				current_hover_object.on_interaction(self)
	else:
		global_transform.origin = lerp(global_transform.origin, puppet_position, 0.3)

puppet func set_puppet_position(pos):
	puppet_position = pos

var color = Color.white
func set_color(c):
	color = c
	var mat: Material = $Model/MeshInstance.get_surface_material(0).duplicate()
	mat.albedo_color = color
	$Model/MeshInstance.set_surface_material(0, mat)

#const PICKUP_BALL = preload("res://Objects/PickUpBall.tscn")
#func update_ball_count():
#	if $BallInventory.get_child_count() != inventory_ball_count:
#		for b in $BallInventory.get_children():
#			b.queue_free()
#		for i in range(inventory_ball_count):
#			var ball = PICKUP_BALL.instance()
#			ball.disable()
#			$BallInventory.add_child(ball)
#			ball.translation.y = i * .3
#
#puppet func set_puppet_ball_count(ball_count):
#	inventory_ball_count = ball_count
#	update_ball_count()

func _network_process(_delta):
	if controlled:
		rpc_unreliable("set_puppet_position", global_transform.origin)
		#rpc_unreliable("set_puppet_ball_count", inventory_ball_count)

var global_2d : Vector2 setget set_global_2d, get_global_2d

func get_global_2d() -> Vector2:
	return Vector2(global_translation.x, global_translation.z)

func set_global_2d(pos):
	global_translation.x = pos.x
	global_translation.z = pos.y
