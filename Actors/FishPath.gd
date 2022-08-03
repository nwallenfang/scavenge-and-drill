extends Path

export var can_attack := false

func _ready():
	$FishEnemy.state = $FishEnemy.STATES.PATH
	$FishEnemy.path = self
	$FishEnemy.can_attack = can_attack
