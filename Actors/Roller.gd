extends Player

export var move_acc_default := 30.0
export var move_acc_upgraded := 40.0

var aim_direction : Vector2
var facing_angle : float

onready var head := $Model/RollerModel/Head
onready var bullet_spawn := $Model/RollerModel/Head/BulletSpawn

onready var handle := $Model/RollerModel/Handle

func _ready():
	._ready()

func _physics_process(delta):
	var old_pos = self.global_2d
	._physics_process(delta)
	var new_pos = self.global_2d
	if controlled:
		if new_pos.distance_to(old_pos) > .01:
			facing_angle = lerp_angle(facing_angle, Vector2(facing_direction.x, -facing_direction.z).angle() + PI / 2.0, 1.0-pow(.005, delta))
			#facing_angle = -old_pos.direction_to(new_pos).angle() + PI / 2.0
			$Model/RollerModel.rotation.y = facing_angle
			#$EndCutscene.rotation.y = facing_angle
	if controlled:
		if static_mode:
			return
		var global_mouse_pos := Game.mouse_layer.get_global_layer_mouse_position()
		if global_mouse_pos == null:
			global_mouse_pos = Vector3(0.0, 0.0, 0.0)
		var direction := Vector2(global_translation.x, global_translation.z).direction_to(Vector2(global_mouse_pos.x, global_mouse_pos.z))
		head.rotation.y = -direction.angle() + PI/2.0 - facing_angle
		aim_direction = direction
		if Input.is_action_just_pressed("shoot"):
			if Game.energy_charges >= 1:
				Game.rpc("sync_energy_charges", Game.energy_charges-1)
				Network.rpc("spawn_object", "bullet", bullet_spawn.global_translation, {"direction": aim_direction})
			else:
				Game.not_enough_crystals()
		if Input.is_action_just_pressed("initiate_swap"):
			if Game.energy_charges >= 2:
				#Game.rpc("sync_energy_charges", Game.energy_charges-2)
				Game.rpc("try_swap",name)
			else:
				Game.not_enough_crystals()
		if Input.is_action_just_pressed("super_mode"):
			Game.rpc("try_super",name)

func _network_process(delta):
	if static_mode:
		return
	._network_process(delta)
	if controlled:
		rpc_unreliable("set_puppet_aim", aim_direction)
		rpc_unreliable("set_puppet_rotation", facing_angle)

remote func set_puppet_rotation(rot):
	self.facing_angle = lerp_angle(facing_angle,rot,.5)
	$Model/RollerModel.rotation.y = facing_angle
	#$EndCutscene.rotation.y = facing_angle

remote func set_puppet_aim(aim_direction_set):
	self.aim_direction = aim_direction_set
	head.rotation.y = -aim_direction.angle() + PI/2.0 - facing_angle
