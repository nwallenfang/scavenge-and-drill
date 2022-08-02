extends Spatial

export var speed := 1.0
var direction : Vector3

func _network_init(data):
	direction = data["direction"]

func _physics_process(delta):
	global_translation += direction * delta * speed
