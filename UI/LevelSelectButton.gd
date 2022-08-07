extends Control


onready var style_box_default: StyleBoxFlat
var style_box_hovered: StyleBoxFlat = preload("res://UI/Styles/panel_menu_button_hovered.tres")

func _ready() -> void:
	style_box_default = $Panel.get("custom_styles/panel") 

signal clicked
func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton

		if event.pressed:
			emit_signal("clicked")

func _on_Panel_mouse_entered() -> void:
	$Panel.set("custom_styles/panel", style_box_hovered)


func _on_Panel_mouse_exited() -> void:
	$Panel.set("custom_styles/panel", style_box_default)


func _on_CreateLobby_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_JoinLobby_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.
