extends Spatial


onready var camera = $Pivot/TopdownCamera

export var player1_color: Color
export var player2_color: Color

const is_level2 := false

func _ready():
	Game.level = self
#	$Player1.set_color(player1_color)
#	$Player2.set_color(player2_color)

	Game.connect("power_depleted", self, "server_power_depleted")
	$WorldEnvironment.environment = load("res://LevelEnvironment.tres")



func server_power_depleted():
	# take care that this doesn't get called twice!
	# (from client and server)
	if is_network_master():
		rpc("power_depleted")

remotesync func power_depleted():
	Game.log("POWER DEPLETED")
	# play some kind of return cut-scene
	Game.execute_contract(true)
	yield(get_tree().create_timer(3),"timeout")
	$Player1.static_mode = true
	$Player2.static_mode = true
	$Player1/Model.visible = false
	$Player2.visible = false
	$Cable.visible = false
	$Player1/EndCutscene.rotation.y = $Player1/Model/RollerModel.rotation.y
	$Player1/EndCutscene.start()
	yield($Player1/EndCutscene,"cutscene_done")
	Game.main.game_to_shop_transition()


var dialog_trigger_possible := false

func do_game_setup(players: Dictionary):
	Game.log("Game Setup")
	Game.dialog_ui.visible = true
	if Game.debug:
		Game.ui.toggle_dev_panel()
	Network.start()
	
	var id_other_player = 1 if get_tree().get_network_unique_id() == 2 else 2

	Game.main_cam = camera   
	

	# STAT UPGRADES
	Game.power_loss_per_s = Game.power_loss_per_s_upgraded if Game.upgrades.less_power_drain else Game.power_loss_per_s_default
	$Player1.ACC = $Player1.move_acc_upgraded if Game.upgrades.more_move_speed else $Player1.move_acc_default
	$Player2.ACC = $Player2.move_acc_upgraded if Game.upgrades.more_move_speed else $Player2.move_acc_default
	if Game.upgrades.chain_longer:
		$Player1.global_translation.x -= 1.0
		$Player2.global_translation.x += 1.0
	
	
	$Cable.create_cable($Player1.handle, $Player2.handle)
	$Cable.set_players($Player1, $Player2)
	
	Game.roller = $Player1
	Game.drill = $Player2
	
	if not get_tree().is_network_server():
		Game.host = false
		$Player2.set_network_master(get_tree().get_network_unique_id())
		$Player2.controlled = true
		Game.own_player = $Player2
		Game.other_player = $Player1
		$Player1.set_network_master(id_other_player)
#		$Viewport/DualSideviewCamera.initialize($Player2, $ViewportPartner/DualSideviewCamera)
#		$ViewportPartner/DualSideviewCamera.initialize($Player1, $Viewport/DualSideviewCamera)
		camera.initialize($Player2, $Player1)
	else:
		Game.host = true
		$Player1.set_network_master(get_tree().get_network_unique_id())
		$Player1.controlled = true
		Game.own_player = $Player1
		Game.other_player = $Player2
		$Player2.set_network_master(id_other_player)
#		$Viewport/DualSideviewCamera.initialize($Player1, $ViewportPartner/DualSideviewCamera)
#		$ViewportPartner/DualSideviewCamera.initialize($Player2, $Viewport/DualSideviewCamera)
		camera.initialize($Player1, $Player2)
	#camera.current = true
	$Player1.visible = false
	$Player2.visible = false
	$Player1.static_mode = true
	$Player2.static_mode = true
	$Cable.visible = false
	Game.ui.fade_in(0.50)
	yield(get_tree().create_timer(0.10), "timeout")
	$DiveStartCutscene.start_cutscene()
	

	yield($DiveStartCutscene,"cutscene_ended")
	Game.ui.back_to_ocean()
	Sound.start_game_sounds()
	Game.ui.fade_out(0.45)
	yield(Game.ui, "fade_done")
	yield(get_tree().create_timer(0.8), "timeout")
	Game.ui.set_game_ui_visible(true)
	$Player1.visible = true
	$Player2.visible = true
	$Player1.static_mode = false
	$Player2.static_mode = false
	$Cable.visible = true
	camera.current = true
	Game.power_draining = true
	Game.ui.init_tutorial_msg()
	Game.ui.fade_in(0.25)
	Game.rpc("sync_energy_charges", 2)
	
	dialog_trigger_possible = true
	$FishBuddy.visible = FishQuest.stage <= 3
	

func replace_collectibles(collectibles_node: Node):
	var collectibles_old = $Collectibles
	collectibles_old.name = "Collectibles_old"
	collectibles_old.queue_free()
	collectibles_node.name = "Collectibles"
	add_child(collectibles_node)


var cooldown_time = 10.0
var count = 0
func _on_CloseToEelDialog_body_entered(body: Node) -> void:
	if body is Player:
		if count > 0:
			if Game.progress.mined_energy_charges == 0:
				# only trigger second time if no energy crystals mined
				Dialog.trigger("close_to_eel")
				return
			else:
				return
		
		Dialog.trigger("close_to_eel")
		$CloseToEelDialog.set_deferred("monitoring", false)
		count += 1
		yield(get_tree().create_timer(cooldown_time), "timeout")
		$CloseToEelDialog.set_deferred("monitoring", true)


func _on_CloseToEelMiddle_body_entered(body):
	if $Player1.visible and dialog_trigger_possible:
		Dialog.trigger("eel_middle")


func _on_SeeWallDialog_body_entered(body):
	if dialog_trigger_possible:
		Dialog.trigger("see_wall")


func _on_OtherSideDialog_body_entered(body):
	if dialog_trigger_possible:
		if not Game.upgrades.position_swap:
			Dialog.trigger("other_side")
		else:
			Dialog.trigger("we_could_teleport")


func _on_FishBuddyDialog_body_entered(body):
	if dialog_trigger_possible:
		if "1" in body.name or "olle" in body.name:
			if FishQuest.stage <= 3:
				if FishQuest.stage == 0:
					Dialog.trigger("buddy_pre_quest")
				else:
					Dialog.trigger("buddy_quest")
					yield(get_tree().create_timer(12),"timeout")
					buddy_away_animation()
					FishQuest.state = 4

func buddy_away_animation():
	Game.log("TODO buddy swims away")
	create_tween().tween_property($FishBuddy, "global_translation", $FishBuddy.global_translation + Vector3(1.0, 10.0, 5.0), 3.0)
