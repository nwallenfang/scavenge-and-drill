extends Control

class_name UI

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

func _physics_process(delta: float) -> void:
	$DevContainer/DeveloperInfo/FPSCounter.text = "FPS: %d" % Engine.get_frames_per_second()
