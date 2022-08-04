extends Control



func _ready() -> void:
	Game.dialog_ui = self
	Dialog.connect("dialog_started", self, "dialog_started")
	$DialogPanel.connect("line_done_naturally", self, "emit_line_done")




# TODO spawn and disappear animation
# idea for spawning: "over-modulate" to have it flash in

# TODO better dialog font


# call this when there is an interrupt
#var panel_invalidated = false  # this has to be true on interrupt
func emit_line_done():
	emit_signal("line_done_or_interrupt")

#remote func remote_for_interrupt():
#	emit_signal("line_done_or_interrupt")

remotesync func play_dialog(dialog_sequence):
	$DialogPanel.visible = true
	for line in dialog_sequence:
		# check which dialogpanel to use
#		panel_invalidated = false
		$DialogPanel.show_dialog_line(line)
		yield(self, "line_done_or_interrupt")
	Dialog.on_dialog_ended()
	
	$DialogPanel.visible = false	

remotesync func hide_all_dialog():
	# interrupt
	$DialogPanel.visible = false


signal line_done_or_interrupt
func dialog_started():  # : Dialog.DialogSequence (thanks cyclic dependencies)
	if is_network_master():  # should only network master start dialogs? hmmmm
		rpc("play_dialog", Dialog.current_dialog_sequence.to_basic_data())


# TODO catch space bar input to skip dialog
signal interrupt
remotesync func skip_dialog():
	Game.log("skip line")
	# TODO if there are multiple panels or different ones this has to change
	$DialogPanel.on_interrupt()
	emit_line_done()
#	panel_invalidated = true
