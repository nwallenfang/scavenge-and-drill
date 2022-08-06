extends Control

export var credit1_time := 8.5
export var credit2_time := 5.5

func _ready() -> void:
	pass # Replace with function body.



func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.physical_scancode == KEY_SPACE:
				timer_or_interrupt()

signal done
func timer_or_interrupt():
	print("time or interrupt")
	emit_signal("done")


signal credits_done
func play_credits():
	visible = true
	$Page1.visible = true
	
	
	$Timer.start(credit1_time)
	yield(self, "done")
	$Page1.visible = false
	$Page2.visible = true
	
	$Timer.start(credit2_time)
	yield(self, "done")
	
	self.visible = false


func _on_Credits_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.physical_scancode == KEY_SPACE:
				timer_or_interrupt()
