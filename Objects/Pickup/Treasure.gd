extends Spatial


func _on_TreasureArea_picked_up() -> void:
	# TODO maybe blend out
	$Mesh.visible = false

func _on_TreasureArea_animation_done() -> void:
	queue_free()
