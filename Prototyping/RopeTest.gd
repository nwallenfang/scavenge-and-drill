extends Spatial


func _ready() -> void:
	Game.game_started = true
	$Player.controlled = true
	
	
func _physics_process(delta: float) -> void:
	pass
	
