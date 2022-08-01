extends Panel

func on_interrupt():
	# connected from outside
	# maybe not needed
	$Timer.stop()




signal line_done_naturally
func show_dialog_line(line):
	Game.log("show line " + line.text)
	# TODO add color
	$"%Name".bbcode_text = "[center]" + Dialog.names[line.speaker_id]
	$"%Text".text = line.text
	
	$Timer.start(line.duration)
	
	# see DialogUI
#	yield(get_parent(), "line_done_or_interrupt")



func _on_Timer_timeout() -> void:
	# line done naturally
	emit_signal("line_done_naturally")
