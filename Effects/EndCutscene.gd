extends Spatial

func _ready() -> void:
	volume = $ChainSound.volume_db

signal cutscene_done
func start():
	visible = true
	$AnimationPlayer.play("Cutscene")
	yield($AnimationPlayer, "animation_finished")
	Dialog.trigger("hook")

func cut_scene_done_emit():
	emit_signal("cutscene_done")

var volume
func play_chain_sound():
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($ChainSound, "volume_db", volume, 0.2).set_ease(Tween.EASE_IN)
	$ChainSound.play()


func stop_chain_sound():
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($ChainSound, "volume_db", -80.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_callback($ChainSound, "stop")
