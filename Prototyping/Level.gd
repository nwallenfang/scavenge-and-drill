extends Spatial


onready var camera = $Pivot/TopdownCamera

export var player1_color: Color
export var player2_color: Color

func _ready():
	Game.level = self
#	$Player1.set_color(player1_color)
#	$Player2.set_color(player2_color)

	Game.connect("power_depleted", self, "server_power_depleted")


func server_power_depleted():
	# take care that this doesn't get called twice!
	# (from client and server)
	if is_network_master():
		rpc("power_depleted")

remotesync func power_depleted():
	# TODO play some kind of return cut-scene
	# TODO merchant sequence
	# wait for start click
	# then reset players to their position
	Game.log("POWER DEPLETED")


func do_game_setup(players: Dictionary):
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
		
		
func replace_collectibles(collectibles_node: Node):
	var collectibles_old = $Collectibles
	collectibles_old.name = "Collectibles_old"
	collectibles_old.queue_free()
	collectibles_node.name = "Collectibles"
	add_child(collectibles_node)
