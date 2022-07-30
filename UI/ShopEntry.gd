extends Control
class_name ShopEntry

signal upgrade_clicked
export var upgrade_attribute: String

var style_box_default: StyleBoxFlat
var style_box_hovered: StyleBoxFlat = preload("res://UI/panel_hovered.tres")


func _ready() -> void:
	style_box_default = $Panel.get("custom_styles/panel")


func _on_Panel_mouse_entered() -> void:
	$Panel.set("custom_styles/panel", style_box_hovered)


func _on_Panel_mouse_exited() -> void:
	$Panel.set("custom_styles/panel", style_box_default)


func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton

		if event.pressed:
			emit_signal("upgrade_clicked", upgrade_attribute)
