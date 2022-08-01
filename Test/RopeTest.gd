extends Spatial


func _ready() -> void:
	Game.game_started = true
	$Player.controlled = true
	#S$Cable.create_cable($Block/Spatial2, $Player/Handle)
