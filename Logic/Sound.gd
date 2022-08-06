extends Node

export var ambience_time := 5.0

func _ready() -> void:
	pass

func start_game_sounds():
	$UnderwaterAmbienceTimer.start(ambience_time)
	start_a_main_theme()
	

func stop_game_sounds():
	$UnderwaterAmbienceTimer.stop()
	$FishAmbienceTimer.stop()
	stop_main_theme()


func drill_talk():
	var rand: int  = (randi() % 3) + 1
	$DrillVoices.get_node("Voice%d" % rand).play()
	
func roller_talk():
	var rand: int  = (randi() % 3) + 1
	$RollerVoices.get_node("Voice%d" % rand).play()


func play_fish_ambience():
	var rand: int  = (randi() % 5) + 1
	$FishAmbiences.get_node("Ambience%d" % rand).play()
	
# should get started stopped in some zones
func _on_FishAmbienceTimer_timeout() -> void:
	play_fish_ambience()

var drill_pos := 0.0
func start_drilling():
	# TODO tween
	$Drilling.play(drill_pos)
	
func stop_drilling():
	# TODO tween
	drill_pos = $Drilling.get_playback_position()
	$Drilling.stop()


var ambi_pos := 0.0
var ambi_vol := -4.0
var trigger_chance = 0.4
var tween_duration = 1.0
func _on_UnderwaterAmbienceTimer_timeout() -> void:
	# trigger on random 50% or smth
	var rand: float = randf()
	if rand < trigger_chance:
		if $UnderwaterAmbience.playing:
			var tween = create_tween().set_trans(Tween.TRANS_QUAD)
			tween.tween_property($UnderwaterAmbience, "volume_db", -80.0, tween_duration).set_ease(Tween.EASE_IN)
			tween.tween_callback($UnderwaterAmbience, "stop")
			ambi_pos = $UnderwaterAmbience.get_playback_position()
		else:
			$UnderwaterAmbience.play(ambi_pos)
			var tween = create_tween().set_trans(Tween.TRANS_QUAD)
			tween.tween_property($UnderwaterAmbience, "volume_db", ambi_vol, tween_duration)

#var themes = [$Themes/ColorsOfTheRainbow, $Themes/SchublerCorals, $Themes/Humuhumu]
var playing: AudioStreamPlayer
var index = 0
func start_a_main_theme():
	index += 1
	index %= 3
	
	playing = $Themes.get_child(index)
	playing.play()
	
func stop_main_theme():
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(playing, "volume_db", -80.0, 1.4)
	tween.tween_callback(playing, "stop")


var shop_dur = 1.0
func start_shop_theme():
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	$FinlandShopTheme.play()
	tween.tween_property($FinlandShopTheme, "volume_db", -16.0, shop_dur).set_ease(Tween.EASE_OUT)
	
func stop_shop_theme():
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($FinlandShopTheme, "volume_db", -80.0, shop_dur).set_ease(Tween.EASE_IN)
	tween.tween_callback($FinlandShopTheme, "stop")
