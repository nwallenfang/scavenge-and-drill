extends Spatial

export var speed := 10.0
var direction : Vector3

func _network_init(data):
	var direction_2d = data["direction"]
	direction = Vector3(direction_2d.x, 0.0, direction_2d.y)

func _physics_process(delta):
	global_translation += direction * delta * speed
