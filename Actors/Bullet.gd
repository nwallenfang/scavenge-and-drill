extends Spatial

export var speed := 10.0
var direction : Vector3

func _ready():
	yield(get_tree().create_timer(3.0),"timeout")
	queue_free()

func _network_init(data):
	var direction_2d = data["direction"]
	direction = Vector3(direction_2d.x, 0.0, direction_2d.y)

func _physics_process(delta):
	global_translation += direction * delta * speed


func _on_Area_area_entered(area):
	queue_free()


func _on_Area_body_entered(body):
	queue_free()
