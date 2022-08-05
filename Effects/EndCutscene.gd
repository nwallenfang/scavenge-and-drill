extends Spatial

signal cutscene_done
func start():
	visible = true
	$AnimationPlayer.play("Cutscene")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("cutscene_done")
