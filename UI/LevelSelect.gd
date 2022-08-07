extends PanelContainer

signal selected_level(number)

func _on_Level2Button_clicked() -> void:
	emit_signal("selected_level", 2)


func _on_Level1Button_clicked() -> void:
	emit_signal("selected_level", 1)
