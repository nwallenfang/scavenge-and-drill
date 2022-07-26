extends CanvasLayer
class_name UILayer

onready var screens = $Screens

signal change_screen (name, screen)
signal back_button ()

var current_screen: Control = null setget _set_readonly_variable
var current_screen_name: String = '' setget _set_readonly_variable, get_current_screen_name

var _is_ready := false

func _set_readonly_variable(_value) -> void:
	pass

func _ready() -> void:
	for screen in screens.get_children():
		if screen.has_method('_setup_screen'):
			screen._setup_screen(self)
	
	show_screen("TitleScreen")
	_is_ready = true

func get_current_screen_name() -> String:
	if current_screen:
		return current_screen.name
	return ''

func show_screen(name: String, info: Dictionary = {}) -> void:
	var screen = screens.get_node(name)
	if not screen:
		return
	
	hide_screen()
	screen.visible = true
	if screen.has_method("_show_screen"):
		screen.callv("_show_screen", [info])
	current_screen = screen
	
	if _is_ready:
		emit_signal("change_screen", name, screen)

func hide_screen() -> void:
	if current_screen and current_screen.has_method('_hide_screen'):
		current_screen._hide_screen()
	
	for screen in screens.get_children():
		screen.visible = false
	current_screen = null

func show_message(text: String) -> void:
	if Game.ui != null:
		var message_label = Game.ui.get_node("Message")
		message_label.text = text
		message_label.visible = true

func hide_message() -> void:
	if Game.ui != null:
		var message_label = Game.ui.get_node("Message")
		message_label.visible = false

func hide_all() -> void:
	hide_screen()
	hide_message()

func _on_BackButton_pressed() -> void:
	emit_signal("back_button")
