extends Spatial

export var value = 1

func _on_PickupArea_body_entered(body: Node) -> void:
	if body is Player:
		Game.treasures += value
		self.queue_free()
