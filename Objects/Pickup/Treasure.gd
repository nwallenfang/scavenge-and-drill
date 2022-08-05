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

var base_scale
func _ready():
	base_scale = $Model.scale

var hp := 1.0
var drilling: bool = false
func get_drilled(amount):
	if not drilling:
		drilling = true
		Game.log("treasure_drill")
		Dialog.trigger("treasure_drill")
	if hp > 0.0:
		hp -= amount
		$Model.scale = base_scale * lerp(.5, 1.0, hp)
		if hp <= 0.0:
			$TreasureArea.picked_up()
