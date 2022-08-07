extends Control

signal done_shopping

func _ready() -> void:
	# connect to all shop entries
	for entry in $VBoxContainer/GridContainer.get_children():
		entry = entry as ShopEntry
		if entry != null:
			entry.connect("upgrade_clicked", self, "upgrade_clicked")
	
	$"%ShopEntrySecret".connect("upgrade_clicked", self, "upgrade_clicked")
	initialize()
	
	# reinitialize to see what's affordable, update treasure count interface
	Game.connect("treasure_count_changed", self, "initialize")
	

var diamonds_were_visible_once = false
func initialize():
	$"%GearAmount".text = "%02d" % Game.treasure_gears
	$"%GoldAmount".text = "%02d" % Game.treasure_gold
	$"%DiamondAmount".text = "%02d" % Game.treasure_diamond
	
	if Game.treasure_diamond > 0:
		diamonds_were_visible_once = true
		$"%DiamondIcon".visible = true
		$"%DiamondAmount".visible = true
		$"%ShopEntrySecret".secret_unlocked = true
	
	for entry in $VBoxContainer/GridContainer.get_children():
		entry = entry as ShopEntry
		if entry == null:
			continue
		if entry.upgrade_attribute in Game.upgrades:
			if Game.upgrades.get(entry.upgrade_attribute):
				entry.bought = true
		else:
			Game.log("shop entry upgrade " + entry.upgrade_attribute + " is unkown.")
		if entry.cost_gears <= Game.treasure_gears and entry.cost_gold <= Game.treasure_gold:
			entry.affordable = true
		else:
			entry.affordable = false
			
func update_treasure():
	$"%GearAmount".text = "%02d" % Game.treasure_gears
	$"%GoldAmount".text = "%02d" % Game.treasure_gold
	$"%DiamondAmount".text = "%02d" % Game.treasure_diamond
	
	if Game.treasure_diamond > 0:
		diamonds_were_visible_once = true
		$"%DiamondIcon".visible = true
		$"%DiamondAmount".visible = true

var phrases = ["That's a good one!", "Good choice!", "Come again!"]
func upgrade_clicked(upgrade_attribute: String, cost_gold: int, cost_gears:int):
	# check that it's buyable even though not buyable upgrades entries should be 
	# disabled
	print("CLICKED " + upgrade_attribute)
	
	if upgrade_attribute == "level_2":
		Game.rpc("set_level2_unlocked")
		return
	
	if not upgrade_attribute in Game.upgrades:
		Game.log("Error: unknown attribute " + upgrade_attribute)
	else:
		Game.rpc("set_upgrade", upgrade_attribute, cost_gold, cost_gears)

func _on_Button_pressed() -> void:
	emit_signal("done_shopping")


func _on_DoneShopping_clicked() -> void:
	if Game.upgrades.level_2:
		$LevelSelect.visible = true
		return
	emit_signal("done_shopping")

func _on_LevelSelect_selected_level(number) -> void:
	if number == 2:
		Game.rpc("set_level2_selected", true)
#		Game.level2_selected = true
	emit_signal("done_shopping")
