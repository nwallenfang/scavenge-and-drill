extends Spatial

signal cutscene_done
func start():
	visible = true
	$AnimationPlayer.play("Cutscene")
	yield($AnimationPlayer, "animation_finished")
	Dialog.trigger("hook")

func cut_scene_done_emit():
	emit_signal("cutscene_done")
