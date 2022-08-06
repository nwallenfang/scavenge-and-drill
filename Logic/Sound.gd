extends Node

func drill_talk():
	var rand: int  = (randi() % 3) + 1
	$DrillVoices.get_node("Voice%d" % rand).play()
	
func roller_talk():
	var rand: int  = (randi() % 3) + 1
	$RollerVoices.get_node("Voice%d" % rand).play()


# should get started stopped in some zones
func _on_FishAmbienceTimer_timeout() -> void:
	pass # Replace with function body.
