extends Control

class_name UI

onready var debug_log := $DevContainer/DeveloperInfo/DebugLog

func toggle_dev_panel():
	$DevContainer.visible = not $DevContainer.visible 
	
func toggle_pause():
	$PausePanel.visible = not $PausePanel.visible 

func _ready() -> void:
	var args = Array(OS.get_cmdline_args())
	var is_player1 = (len(args) >= 2 and args[1] == 'player1')
	if len(args) >= 1:
		if args[0] == 'debug':
			Game.debug = true
			$DevContainer/DeveloperInfo/HostOrClient.text = "host" if is_player1 else "client"
	debug_log.text += "Logs will be printed here\n"
	# make mats unique
	var box = $"%EnergyCrystalsBox"

	box.get_node("AspectRatioContainer1/ColorRect").material = box.get_node("AspectRatioContainer1/ColorRect").material.duplicate(true)
	box.get_node("AspectRatioContainer2/ColorRect").material = box.get_node("AspectRatioContainer1/ColorRect").material.duplicate(true)
	box.get_node("AspectRatioContainer3/ColorRect").material = box.get_node("AspectRatioContainer1/ColorRect").material.duplicate(true)
	box.get_node("AspectRatioContainer4/ColorRect").material = box.get_node("AspectRatioContainer1/ColorRect").material.duplicate(true)
	box.get_node("AspectRatioContainer5/ColorRect").material = box.get_node("AspectRatioContainer1/ColorRect").material.duplicate(true)
	set_energy_charges(Game.energy_charges)

func init_tutorial_msg():
	$"%TutorialPanel".visible = true
	if Game.drill.controlled:
		$"%TutorialMsg".text = "Explore and find treasures!\nLeft Mouse Button to drill"
	else:
		$"%TutorialMsg".text = "Explore and find treasures!\nLeft Mouse Button to shoot"
	if Game.upgrades.super_mode:
		$"%TutorialMsg".text += "\n Press [F] for invincibility"
	if Game.upgrades.position_swap:
		$"%TutorialMsg".text += "\n Press [T] to swap positions"
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dev_toggle"):
		toggle_dev_panel()

func _physics_process(delta: float) -> void:
	$DevContainer/DeveloperInfo/FPSCounter.text = "FPS: %d" % Engine.get_frames_per_second()

func add_to_log(msg: String):
	debug_log.text += msg + '\n'
	debug_log.cursor_set_line(debug_log.get_line_count())
	
	
func set_power(value_percent: float):
	$"%PowerProgress".material.set_shader_param("value", value_percent)


func update_treasures_without_pop_in():
	$"%GoldAmount".text = "%02d" % Game.treasure_gold	
	$"%GearAmount".text = "%02d" % Game.treasure_gears
	$"%DiamondAmount".text = "%02d" % Game.treasure_diamond	

var blended_out: Color = Color("00ffffff")
var blended_in: Color  = Color("ffffffff")
func update_treasures(treasure_type: int):
	# type: type of the treasure amount that changed for animations maybe
	var tween = create_tween()
	
	# TODO if treasure ui not blended out yet.. skip this first tween
	tween.tween_property($"%TreasureUI", "modulate", blended_in, 0.3)
	tween.play()
	yield(tween, "finished")
	# tween treasure interface in
	match treasure_type:
		1:
			$"%GoldAmount".text = "%02d" % Game.treasure_gold
		2:
			$"%GearAmount".text = "%02d" % Game.treasure_gears
		3:
			$"%DiamondAmount".text = "%02d" % Game.treasure_diamond
			$"%DiamondAmount".visible = true
			$"%DiamondIcon".visible = true
			
	# TODO maybe even play a nice animation for the number that got increased
	# for even more polish

	yield(get_tree().create_timer(3.0), "timeout")
	tween = create_tween()
	tween.tween_property($"%TreasureUI", "modulate", blended_out, 0.4)
	tween.play()
	
	
func set_rope_length(s):
	$"%RopeLength".text = s
	
	
func to_shop():
	$Game.visible = false
	$Game/CanvasLayer.visible = false
	
func back_to_ocean():
	$Game.visible = true
	$Game/CanvasLayer.visible = true
	
	
func set_game_ui_visible(val: bool):
	$Game.visible = val
	$Game/CanvasLayer.visible = val
	
func set_energy_charges(val: int):
	var full_charges := int(val / 2.0)
	var half_charge: bool = (val % 2) == 1
	
	for i in range(full_charges):
		var rect = $"%EnergyCrystalsBox".get_node("AspectRatioContainer" + str(i+1)).get_node("ColorRect")
		rect.material.set("shader_param/enabled", true)
		rect.material.set("shader_param/half_enabled", false)
		
	if half_charge:
		var rect = $"%EnergyCrystalsBox".get_node("AspectRatioContainer" + str(full_charges+1)).get_node("ColorRect")
		rect.material.set("shader_param/enabled", false)
		rect.material.set("shader_param/half_enabled", true)
		
	# rest is not enabled
	if half_charge:
		for i in range(full_charges + 1, 5):
			var rect = $"%EnergyCrystalsBox".get_node("AspectRatioContainer" + str(i+1)).get_node("ColorRect")
			rect.material.set("shader_param/enabled", false)
			rect.material.set("shader_param/half_enabled", false)
	else:
		for i in range(full_charges, 5):
			var rect = $"%EnergyCrystalsBox".get_node("AspectRatioContainer" + str(i+1)).get_node("ColorRect")
			rect.material.set("shader_param/enabled", false)
			rect.material.set("shader_param/half_enabled", false)

var fade_faded_out: Color = Color("ff000000")
var fade_faded_in: Color = Color("00000000")  # looks funny lol
signal fade_done
func fade_out(speed: float):
	var tween = create_tween()
	tween.tween_property($FadeRect, "color", fade_faded_out, speed)
	yield(tween, "finished")
	emit_signal("fade_done")

func fade_in(speed: float):
	var tween = create_tween()
	tween.tween_property($FadeRect, "color", fade_faded_in, speed)
	yield(tween, "finished")
	emit_signal("fade_done")
	
func vignette_hit_effect():
	$VignetteHitPlayer.play("get_hit")
	

export var missing_value: float setget set_missing_value
func set_missing_value(value: float):
	if not is_inside_tree():
		return
	var box = $"%EnergyCrystalsBox"
	for i in range(1, box.get_child_count()+1):
		box.get_node("AspectRatioContainer%d/ColorRect" % i).material.set_shader_param("missing_progress", value)

	
func show_energy_crystals_missing():
	$CrystalsEmpty.play()
	$EnergyCrystalPlayer.play("energy_crystal_missing")

