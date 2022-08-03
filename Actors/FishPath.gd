extends Path

export var can_attack := false

func _ready():
	for i in range(curve.get_point_count()):
		var pos = curve.get_point_position(i)
		pos.y = 0.0
		curve.set_point_position(i, pos)
	$FishEnemy.state = $FishEnemy.STATES.PATH
	$FishEnemy.path = self
	$FishEnemy.can_attack = can_attack
	$FishEnemy.visible = true
	$FishEnemy.global_translation = curve.interpolate_baked(0.0)
