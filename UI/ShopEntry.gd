extends Control
class_name ShopEntry

signal upgrade_clicked
export var upgrade_attribute: String

func _ready() -> void:
	pass 


func _on_TextureButton_pressed() -> void:
	emit_signal("upgrade_clicked", upgrade_attribute)

