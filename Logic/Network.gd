extends Node

export var TICK_RATE = 30 # 1/s

var nodes: Array

func _ready() -> void:
	$Timer.wait_time = 1.0/TICK_RATE


func start():
	$Timer.start()

func _on_Timer_timeout() -> void:
	get_tree().call_group("networked", "_network_process", 1.0/TICK_RATE)
