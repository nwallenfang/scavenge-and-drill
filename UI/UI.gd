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

func _physics_process(delta: float) -> void:
	$DevContainer/DeveloperInfo/FPSCounter.text = "FPS: %d" % Engine.get_frames_per_second()

func add_to_log(msg: String):
	debug_log.text += msg + '\n'
	debug_log.cursor_set_line(debug_log.get_line_count())
	
	
func set_o2(value_percent: float):
	$"%OxygenProgress".value = value_percent
