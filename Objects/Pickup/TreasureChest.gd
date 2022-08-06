extends Spatial

func open():
	$AnimationPlayer.play("open")

func close():
	yield(get_tree().create_timer(1.0),"timeout")
	$AnimationPlayer.play("close")
