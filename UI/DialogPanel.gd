extends PanelContainer

func on_interrupt():
	# connected from outside
	# maybe not needed
	$Timer.stop()


signal line_done_naturally
func show_dialog_line(line):
	Game.log("show line " + line.text)
	# TODO add color
	var color_hex = Dialog.colors[line.speaker_id].to_html()
	var color_bb = "[color=#%s]" % color_hex
#	$"%Name".bbcode_text = "[center]" + color_bb + Dialog.names[line.speaker_id]
	# maybe make the text the same color? don't know
	$"%Text".text = line.text
	$"%Icon".material.set("shader_param/texture_resource", Dialog.icons[line.speaker_id])
	$Timer.start(line.duration)
	
	# see DialogUI
#	yield(get_parent(), "line_done_or_interrupt")



func _on_Timer_timeout() -> void:
	# line done naturally
	emit_signal("line_done_naturally")
