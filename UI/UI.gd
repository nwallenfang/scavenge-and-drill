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
	print(box.get_node("AspectRatioContainer1/ColorRect"))
	box.get_node("AspectRatioContainer1/ColorRect").material = box.get_node("AspectRatioContainer1/ColorRect").material.duplicate(true)
	box.get_node("AspectRatioContainer2/ColorRect").material = box.get_node("AspectRatioContainer1/ColorRect").material.duplicate(true)
	box.get_node("AspectRatioContainer3/ColorRect").material = box.get_node("AspectRatioContainer1/ColorRect").material.duplicate(true)
#	set_energy_crystals(2)
	
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
			printerr("Treasure type 3 not implemented!")
			
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
	
func back_to_ocean():
	$Game.visible = true
	
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
		for i in range(full_charges + 1, 3):
			var rect = $"%EnergyCrystalsBox".get_node("AspectRatioContainer" + str(i+1)).get_node("ColorRect")
			rect.material.set("shader_param/enabled", false)
			rect.material.set("shader_param/half_enabled", false)
	else:
		for i in range(full_charges, 3):
			var rect = $"%EnergyCrystalsBox".get_node("AspectRatioContainer" + str(i+1)).get_node("ColorRect")
			rect.material.set("shader_param/enabled", false)
			rect.material.set("shader_param/half_enabled", false)
