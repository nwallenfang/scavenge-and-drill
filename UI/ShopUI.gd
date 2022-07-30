extends Control

signal done_shopping

func _ready() -> void:
	# connect to all shop entries
	for entry in $VBoxContainer/GridContainer.get_children():
		entry = entry as ShopEntry
		entry.connect("upgrade_clicked", self, "upgrade_clicked")
		

func initialize():
	$"%GearAmount".text = "%02d" % Game.treasure_gears
	$"%GoldAmount".text = "%02d" % Game.treasure_gold


func upgrade_clicked(upgrade_attribute: String):
	# check that it's buyable even though not buyable upgrades entries should be 
	# disabled
	print("CLICKED " + upgrade_attribute)
	
	# TODO reduce resources gears/gold
	
	if not upgrade_attribute in Game.upgrades:
		Game.log("Error: unknown attribute " + upgrade_attribute)
	else:
		Game.rpc("set_upgrade", upgrade_attribute)


func _on_Button_pressed() -> void:
	emit_signal("done_shopping")
