extends Spatial

export var speed := 15.0
export var friction := .4
var direction : Vector3

func _ready():
	if Game.upgrades.more_bullet_damage:
		$BulletModel.scale *= 1.5
	yield(get_tree().create_timer(3.0),"timeout")
	queue_free()

func _network_init(data):
	var direction_2d = data["direction"]
	direction = Vector3(direction_2d.x, 0.0, direction_2d.y)
	global_rotation.y = -direction_2d.angle() - PI / 2.0

func _physics_process(delta):
	global_translation += direction * delta * speed
	speed = speed * pow(friction, delta)


func _on_Area_area_entered(area):
	visible = false
	$Area.set_deferred("monitoring", false)
	$Area.set_deferred("monitorable", false)


func _on_Area_body_entered(body):
	visible = false
	$Area.set_deferred("monitoring", false)
	$Area.set_deferred("monitorable", false)
