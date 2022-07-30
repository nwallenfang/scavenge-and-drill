extends Control

func _ready() -> void:
	pass # Replace with function body.


func show():
	$"%GearAmount".text = "%02d" % Game.treasure_gears
	$"%GoldAmount".text = "%02d" % Game.treasure_gold
