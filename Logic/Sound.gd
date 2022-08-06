extends Node

func drill_talk():
	var rand: int  = (randi() % 3) + 1
	$DrillVoices.get_node("Voice%d" % rand).play()
	
func roller_talk():
	var rand: int  = (randi() % 3) + 1
	$RollerVoices.get_node("Voice%d" % rand).play()


func play_fish_ambience():
	var rand: int  = (randi() % 5) + 1
	$FishAmbiences.get_node("Ambience%d" % rand).play()
	
# should get started stopped in some zones
func _on_FishAmbienceTimer_timeout() -> void:
	play_fish_ambience()

var drill_pos := 0.0
func start_drilling():
	$Drilling.play(drill_pos)
	
func stop_drilling():
	drill_pos = $Drilling.get_playback_position()
	$Drilling.stop()


func _on_UnderwaterAmbienceTimer_timeout() -> void:
	pass # Replace with function body.
	var trigger = true
	# trigger on random 50% or smth
	
