extends Spatial

export var player1_color: Color
export var player2_color: Color

func _ready():
	$TopdownCamera.set_physics_process(false)
	$TopdownCamera.set_process(false)
	
	$Player1.set_color(player1_color)
	$Player2.set_color(player2_color)

var game_started := false
var game_over := false
var players_setup := {}

signal game_started ()
signal game_over (player_id)

func game_start(players: Dictionary) -> void:
	if Game.online_play:
		rpc("_do_game_setup", players)
	else:
		_do_game_setup(players)

# Initializes the game so that it is ready to really start.
remotesync func _do_game_setup(players: Dictionary) -> void:
	Network.start()
	
	if game_started:
		game_stop()
	
	game_started = true
	game_over = false
	
#	print(players)
#	print(get_tree().get_network_unique_id())
	var id_other_player = 1 if get_tree().get_network_unique_id() == 2 else 2

	if not get_tree().is_network_server():
		$Player2.set_network_master(get_tree().get_network_unique_id())
		$Player2.controlled = true
		Game.own_player = $Player2
		Game.other_player = $Player1
		$Player1.set_network_master(id_other_player)
		$TopdownCamera.initialize($Player2)
	else:
		$Player1.set_network_master(get_tree().get_network_unique_id())
		$Player1.controlled = true
		Game.own_player = $Player1
		Game.other_player = $Player2
		$Player2.set_network_master(id_other_player)
		$TopdownCamera.initialize($Player1)

	$TopdownCamera.set_physics_process(true)
	$TopdownCamera.set_process(true)

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
	emit_signal("game_started")
	get_tree().set_pause(false)


func game_stop() -> void:
	game_started = false
