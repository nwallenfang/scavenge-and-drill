tool
extends Spatial

export var version := 1 setget set_version
func set_version(v):
	version = v
	$Model.set_version(v)

func _on_TreasureArea_picked_up() -> void:
	# TODO maybe blend out
	$Model.visible = false

func _on_TreasureArea_animation_done() -> void:
	queue_free()
