extends Player

export var move_acc_default := 8.0
export var move_acc_upgraded := 12.0

onready var handle := $Handle

var mounted := false setget set_mounted

func set_mounted(m):
	mounted = m
	$CollisionShape.disabled = m

func _physics_process(delta):
	if mounted:
		self.global_2d = Game.roller.global_2d
		return
	._physics_process(delta)
	if controlled:
		if Input.is_action_just_pressed("initiate_swap"):
			Game.rpc("try_swap", name)
		if Input.is_action_just_pressed("super_mode"):
			Game.rpc("try_super", name)

func _network_process(delta):
	if not mounted:
		._network_process(delta)
