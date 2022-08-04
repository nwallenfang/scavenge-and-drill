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

var hp := 1.0
func get_drilled(amount):
	hp -= amount
	$Model.scale = lerp(.5, 1.0, hp)
	if hp <= 0.0:
		$TreasureArea.picked_up()
