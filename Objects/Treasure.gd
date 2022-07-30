extends Spatial

export var amount = 2
export var type = 1


func _on_PickupArea_body_entered(body: Node) -> void:
	if body is Player:
		if is_network_master():
			Game.rpc("sync_treasures", amount, type)
		self.queue_free()
