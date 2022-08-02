extends Path

func _ready():
	$FishEnemy.state = $FishEnemy.STATES.PATH
	$FishEnemy.path = self
