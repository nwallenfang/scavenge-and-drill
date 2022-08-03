extends Player

export var move_acc_default := 120.0
export var move_acc_upgraded := 130.0

func _physics_process(delta):
	._physics_process(delta)
	if controlled:
		if Input.is_action_just_pressed("initiate_swap"):
			Game.try_swap(name)
