extends Spatial


func _ready() -> void:
	Game.game_started = true
	$Player.controlled = true
	
	
func _physics_process(delta: float) -> void:
	$MovingBlock.apply_central_impulse(0.05 * Vector3.LEFT)
	
