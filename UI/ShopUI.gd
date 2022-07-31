extends Control

signal done_shopping

func _ready() -> void:
	# connect to all shop entries
	for entry in $VBoxContainer/GridContainer.get_children():
		entry = entry as ShopEntry
		entry.connect("upgrade_clicked", self, "upgrade_clicked")
	initialize()
	
	# reinitialize to see what's affordable, update treasure count interface
	Game.connect("treasure_count_changed", self, "initialize")


func initialize():
	$"%GearAmount".text = "%02d" % Game.treasure_gears
	$"%GoldAmount".text = "%02d" % Game.treasure_gold
	
	
	for entry in $VBoxContainer/GridContainer.get_children():
		entry = entry as ShopEntry
		
		if entry.cost_gears <= Game.treasure_gears and entry.cost_gold <= Game.treasure_gold:
			entry.affordable = true
		else:
			entry.affordable = false
			
func update_treasure():
	$"%GearAmount".text = "%02d" % Game.treasure_gears
	$"%GoldAmount".text = "%02d" % Game.treasure_gold


func upgrade_clicked(upgrade_attribute: String, cost_gold: int, cost_gears:int):
	# check that it's buyable even though not buyable upgrades entries should be 
	# disabled
	print("CLICKED " + upgrade_attribute)
	
	# TODO reduce resources gears/gold
	
	if not upgrade_attribute in Game.upgrades:
		Game.log("Error: unknown attribute " + upgrade_attribute)
	else:
		Game.rpc("set_upgrade", upgrade_attribute, cost_gold, cost_gears)
		


func _on_Button_pressed() -> void:
	emit_signal("done_shopping")
