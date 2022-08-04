extends KinematicBody

class_name GroundedPhysicsMover3D

# no problem if the game runs at a different FPS, it's just for readability
const EXPECTED_FPS := 60

export var FRICTION := 0.85
export var ACC := 100.0

var velocity := Vector3.ZERO 
var acceleration := Vector3.ZERO 
#var gravity_enabled = true setget set_gravity_enabled
#var snap_vector := Vector3.DOWN
#var up_vector := Vector3.UP


var floor_max_angle = deg2rad(50.0)
var max_slides = 4
var stop_on_slopes = true

# height of the player collider
# this hard-coded value needs to be changed if the player collider changes
var capsule_height = 1.0
# height the player should be able to overcome
var max_warp_height = 0.3
var min_warp_height = 0.0

var dead_direction := Vector3.ZERO


func add_acceleration(var added_acc: Vector3):
	acceleration += added_acc
	
func add_plane_acceleration(var added_acc: Vector2):
	acceleration += Vector3(added_acc.x, 0, added_acc.y)

func accelerate_and_move(delta: float, acceleration_direction: Vector3 = Vector3.ZERO, acceleration_strength: float = ACC) -> void:
	var added_acc: Vector3
	if acceleration_direction.is_normalized():
		added_acc = acceleration_direction * acceleration_strength
	else:
		added_acc = acceleration_direction.normalized() * acceleration_strength
		
	acceleration += added_acc
		
	execute_movement(delta)

func get_in_plane_acceleration() -> Vector2:
	# returns 2d acceleration vector (x, z), so (left/right, forward/backward)
	return Vector2(acceleration.x, acceleration.z)

func execute_movement(delta: float) -> void:
	velocity += acceleration * delta
	# apply friction if on the floor
	velocity = velocity * pow(FRICTION, delta * EXPECTED_FPS)
	
#	if dead_direction != Vector3.ZERO:
#		velocity -= velocity.project(dead_direction)
#		dead_direction = Vector3.ZERO
	
	if velocity.length() < 0.05:
		# to prevent long sliding down ramps
		velocity = Vector3.ZERO
		
#	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, stop_on_slopes, max_slides, floor_max_angle)
	velocity = move_and_slide(velocity, Vector3.UP, stop_on_slopes, max_slides, floor_max_angle)
#	var collision: KinematicCollision = get_last_slide_collision()
#
#	if collision != null:
#		var height = capsule_height + (collision.position.y - global_transform.origin.y)
#		if height > min_warp_height and height < max_warp_height and Input.is_action_pressed("move_forward"):
#			translate(Vector3(0.0, height, 0.0))

	acceleration = Vector3.ZERO 

