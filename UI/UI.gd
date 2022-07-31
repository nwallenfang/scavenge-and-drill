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
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dev_toggle"):
		toggle_dev_panel()

func _physics_process(delta: float) -> void:
	$DevContainer/DeveloperInfo/FPSCounter.text = "FPS: %d" % Engine.get_frames_per_second()

func add_to_log(msg: String):
	debug_log.text += msg + '\n'
	debug_log.cursor_set_line(debug_log.get_line_count())
	
	
func set_o2(value_percent: float):
	$"%OxygenProgress".value = value_percent
	

var blended_out: Color = Color("00ffffff")
var blended_in: Color  = Color("ffffffff")
func set_treasure(treasures: int, treasure_type: int):
	var tween = create_tween()
	
	# TODO if treasure ui not blended out yet.. skip this first tween
	tween.tween_property($"%TreasureUI", "modulate", blended_in, 0.3)
	tween.play()
	yield(tween, "finished")
	# tween treasure interface in
	match treasure_type:
		1:
			$"%GoldAmount".text = "%02d" % treasures
		2:
			$"%GearAmount".text = "%02d" % treasures
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

