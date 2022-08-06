extends Control
class_name ShopEntrySecret
signal upgrade_clicked
export var upgrade_attribute: String
export var description: String
export var cost_gears: int = 1
export var cost_gold: int = 2
export var upgrade_icon: StreamTexture


const unaffordable_color: Color = Color("c24040")
const unaffordable_modulate: Color = Color("2bffffff")
const affordable_color: Color = Color.white

var style_box_default: StyleBoxFlat
var style_box_hovered: StyleBoxFlat = preload("res://UI/Styles/panel_hovered.tres")
var style_box_not_affordable: StyleBoxFlat = preload("res://UI/Styles/panel_not_affordable.tres")
var style_box_bought: StyleBoxFlat = preload("res://UI/Styles/panel_bought.tres")
var affordable = false setget set_affordable
var bought = false setget set_bought
var secret_unlocked = false setget set_secret_unlocked

func _ready() -> void:
	style_box_default = $Panel.get("custom_styles/panel")
	$"%DescriptionLabel".text = description
	$"%Image".material = $"%Image".material.duplicate(true)
	if upgrade_icon != null:
		$"%Image".material.set_shader_param("texture_resource", upgrade_icon)
	
func set_affordable(val: bool):
	if not val and affordable and not bought:  # switch away
		$Panel.set("custom_styles/panel", style_box_not_affordable)
		$"%Image".modulate = unaffordable_modulate
	if val and not affordable and not bought:  # switch back
		$Panel.set("custom_styles/panel", style_box_default)
		$"%Image".modulate = Color.white
		
	affordable = val

const entry_font = preload("res://Assets/Fonts/ShopEntryFont.tres")
func set_secret_unlocked(value: bool):
	if value and not secret_unlocked:
		$"%DescriptionLabel".text = "Unlock another World"
		$"%DescriptionLabel".set("custom_fonts/font", entry_font)
		$"%Cost".visible = true
		$"%Image".visible = true
		$"%DiamondAmount".text = "1"
		set_affordable(true)
		
	secret_unlocked = value

func _on_Panel_mouse_entered() -> void:
	if affordable and not bought:
		$Panel.set("custom_styles/panel", style_box_hovered)


func _on_Panel_mouse_exited() -> void:
	if affordable and not bought:
		$Panel.set("custom_styles/panel", style_box_default)


remotesync func set_bought(val: bool):
	if val:
		$Panel.set("custom_styles/panel", style_box_bought)
		$"%Image".modulate = unaffordable_modulate
		$"%DiamondAmount".text = '-'
	if bought and not val:
		Game.log("unbuy shouldn't happen")
		printerr("unbuy shouldn't happen")

	bought = val
	


func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton

		if event.pressed and affordable:
			if bought:
				return
			emit_signal("upgrade_clicked", upgrade_attribute, cost_gold, cost_gears)
			rpc("set_bought", true)

