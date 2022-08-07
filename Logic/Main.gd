extends Control

#onready var game = $Level
#onready var ui_layer: UILayer = $UILayer
onready var ready_screen = $ReadyScreen
var level

var players := {}

var players_ready := {}
var players_score := {}

var game_started := false
var game_over := false
var players_setup := {}


signal game_started ()
signal game_over (player_id)

func _ready() -> void:
	# set Game.debug depending on cmd arguments (added by MultiRun addon)
	var args = Array(OS.get_cmdline_args())
	var is_player1 = (len(args) >= 2 and args[1] == 'player1')
	if len(args) >= 1:
		if args[0] == 'debug':
			Game.debug = true

	OnlineMatch.connect("error", self, "_on_OnlineMatch_error")
	OnlineMatch.connect("disconnected", self, "_on_OnlineMatch_disconnected")
	OnlineMatch.connect("player_status_changed", self, "_on_OnlineMatch_player_status_changed")
	OnlineMatch.connect("player_left", self, "_on_OnlineMatch_player_left")
	OnlineMatch.connect("matchmaker_matched", self, "_on_OnlineMatch_matchmaker_matched")
	
	
	if Game.debug:
		# other instance should wait a little because the first instance 
		# becomes the server
		if not is_player1:
			yield(get_tree().create_timer(.3), "timeout")
		Network.connect_to_matchmaking()
	
	Game.main = self
	#Game.connect("power_depleted", self, "game_to_shop_transition")
	get_viewport().connect("size_changed", self, "resize_viewport")
	self.resize_viewport()

func resize_viewport():
	$ViewportContainer/Viewport.size = get_viewport().size

remotesync func start_playing():
	OnlineMatch.start_playing()

func _on_OnlineMatch_matchmaker_matched(_players: Dictionary):
#	ui_layer.show_screen("ReadyScreen", { players = _players })
#	$ReadyScreen._show_screen({ players = _players })
	# -> ready

	print("MISSING SOMETHING HERE")
	if Game.debug:
		rpc("player_ready", OnlineMatch.get_my_session_id())
#		start_game()
#		rpc("start_playing")
#	start_game()

#####
# OnlineMatch callbacks
#####

func _on_OnlineMatch_error(message: String):
	print("Match error ", message)
	Game.log("Match error: " + message)

func _on_OnlineMatch_disconnected():
	_on_OnlineMatch_error("Disconnected from host")

func _on_OnlineMatch_player_left(player) -> void:
	Game.log(player.username + " has left")
	
	players.erase(player.peer_id)
	players_ready.erase(player.peer_id)

func _on_OnlineMatch_player_status_changed(player, status) -> void:
	if status == OnlineMatch.PlayerStatus.CONNECTED:
		if get_tree().is_network_server():
			# Tell this new player about all the other players that are already ready.
			for session_id in players_ready:
				rpc_id(player.peer_id, "player_ready", session_id)

#####
# Gameplay methods and callbacks
#####
remotesync func player_ready(session_id: String) -> void:
#	ready_screen.set_status(session_id, "READY!")
	if get_tree().is_network_server() and not players_ready.has(session_id):
		players_ready[session_id] = true
		if players_ready.size() == OnlineMatch.players.size():
			if OnlineMatch.match_state != OnlineMatch.MatchState.PLAYING:
				OnlineMatch.start_playing()
			start_game()

func start_game() -> void:
	players = OnlineMatch.get_player_names_by_peer_id()
	print("START GAME@@")
	if get_tree().is_network_server():
		rpc("_do_game_setup", players)


func stop_game() -> void:
	OnlineMatch.leave()
	
	players.clear()
	players_ready.clear()
	players_score.clear()
	game_started = false

func restart_game() -> void:
	stop_game()
	start_game()


# Initializes the game so that it is ready to really start.
const LEVEL_SCENE = preload("res://Prototyping/Level.tscn")
const LEVEL2_SCENE = preload("res://Prototyping/Level2.tscn")
remotesync func _do_game_setup(playerss: Dictionary) -> void:
	$UI.visible = true
	$UI.fade_out(0.6)
	yield($UI, "fade_done")
	$MainMenu.queue_free()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if game_started:
		stop_game()
	
	game_started = true
	game_over = false
	
	level = LEVEL_SCENE.instance()

	
	$ViewportContainer/Viewport.add_child(level)
#	$ViewportContainer.enable_dither()
#	$ViewportContainer.enable_post_processing()
	Game.ui = $UI
	Game.ui.visible = true
	level.do_game_setup(playerss)
	
	$ViewportContainer.visible = true


	if Game.online_play:
		var my_id := get_tree().get_network_unique_id()
		# Tell the host that we've finished setup.
		rpc_id(1, "_finished_game_setup", my_id)

# Records when each player has finished setup so we know when all players are ready.
mastersync func _finished_game_setup(player_id: int) -> void:
	players_setup[player_id] = true
	if players_setup.size() == 2:
		# Once all clients have finished setup, tell them to start the game.
		rpc("_do_game_start")

# Actually start the game on this client.
remotesync func _do_game_start() -> void:
#	emit_signal("game_started")
	$ReadyScreen.visible = false
	Game.game_started = true
	get_tree().set_pause(false)

func _on_ReadyScreen_ready_pressed() -> void:
	rpc("player_ready", OnlineMatch.get_my_session_id())
	
func game_to_shop_transition():
	Sound.stop_game_sounds()
	Sound.start_shop_theme()
	Game.ui.fade_out(0.3)
	yield(Game.ui, "fade_done")
	$ShopUI.visible = true
	$DialogUI.visible = false  # have to change this once we want the merchant to talk fix mouse masks then!!
	$ShopUI.initialize()
	$ViewportContainer.visible = false
	$UI.to_shop()
	Game.ui.fade_in(0.3)
	
	yield($ShopUI, "done_shopping")
	rpc("shop_to_game_transition")
	
remotesync func shop_to_game_transition():
	Sound.get_node("BackToOceanSound").play()
	Game.ui.init_tutorial_msg()
	Game.ui.fade_out(0.3)
	Game.game_started = false
	yield(Game.ui, "fade_done")
	Game.ui.update_treasures(1)
	Game.ui.update_treasures(2)
	if $ShopUI.diamonds_were_visible_once:
		Game.ui.update_treasures(3)
	Game.power_draining = false
	var new_level
	var collectibles
	
	if level.is_level2:
		Game.collectibles_level2 = level.get_node("Collectibles").duplicate()
	else:  # level 1
		Game.collectibles_node = level.get_node("Collectibles").duplicate()

	if Game.level2_selected:
		new_level = LEVEL2_SCENE.instance()
		collectibles = Game.collectibles_level2
	else:
		new_level = LEVEL_SCENE.instance()
		collectibles = Game.collectibles_node
		
	# if there is a lag/loading here we can put most of this in method just above this one
	$ViewportContainer/Viewport.remove_child(level)
	$ViewportContainer/Viewport.add_child(new_level)
	new_level.name = "Level"
	new_level.do_game_setup({})
	if collectibles != null:
		new_level.replace_collectibles(collectibles)
	level.queue_free()
	$ShopUI.visible = false
	$ViewportContainer.visible = true
	$UI.back_to_ocean()
	Game.ui.fade_in(0.3)
	Game.power = Game.max_power
	level = new_level
	Game.try_count += 1   
	Game.rpc("sync_energy_charges", 0)
	Game.game_started = true
	Sound.stop_shop_theme()
#	Sound.start_game_sounds()
	
	
func _on_MainMenu_match_made():
#	rpc("start_playing")
	start_game()
