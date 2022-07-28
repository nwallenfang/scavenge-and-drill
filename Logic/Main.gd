extends Spatial

onready var game = $Level
onready var ui_layer: UILayer = $UILayer
onready var ready_screen = $UILayer/Screens/ReadyScreen

var players := {}

var players_ready := {}
var players_score := {}

func _ready() -> void:
	Game.viewport_sprite = $Sprite
	
	var args = Array(OS.get_cmdline_args())
	var is_player1 = (len(args) >= 2 and args[1] == 'player1')


	OnlineMatch.connect("error", self, "_on_OnlineMatch_error")
	OnlineMatch.connect("disconnected", self, "_on_OnlineMatch_disconnected")
	OnlineMatch.connect("player_status_changed", self, "_on_OnlineMatch_player_status_changed")
	OnlineMatch.connect("player_left", self, "_on_OnlineMatch_player_left")
	
	if Game.debug:
		# other instance should wait a little because the first instance 
		# becomes the server
		if not is_player1:
			yield(get_tree().create_timer(0.2), "timeout")
		connect_to_matchmaking()


# copied from MatchScreen and ConnectionScreen
func connect_to_matchmaking():
	# first off authenticate with Nakama
	# TODO device ID not available on Web, need to find an alternative!
	var device_id = OS.get_unique_id()
	var username = 'Milhelm'  # let player choose their name?
	var nakama_session = yield(Online.nakama_client.authenticate_device_async(device_id, username, true, null), "completed")
	
	if nakama_session.is_exception():
		visible = true
		ui_layer.show_message("Login failed!")
		print("Login failed!")
		print(nakama_session.get_exception())
		# We always set Online.nakama_session in case something is yielding
		# on the "session_changed" signal.
		Online.nakama_session = null
	else:
		Online.nakama_session = nakama_session
	
	# Connect socket to realtime Nakama API if not connected.
	if not Online.is_nakama_socket_connected():
		Online.connect_nakama_socket()
		yield(Online, "socket_connected")
		
	ui_layer.hide_screen()
	ui_layer.show_message("Looking for match...")
	
	var data = {
		min_count = 2,
		string_properties = {
			game = "test_game",
		},
		query = "+properties.game:test_game",
	}
	
	OnlineMatch.start_matchmaking(Online.nakama_socket, data)

#####
# UI callbacks
#####

func _on_TitleScreen_play_local() -> void:
	Game.online_play = false
	
	ui_layer.hide_screen()
	ui_layer.show_back_button()
	
	start_game()

func _on_TitleScreen_play_online() -> void:
	Game.online_play = true
	
	ui_layer.show_screen("ConnectionScreen")

func _on_UILayer_change_screen(name: String, _screen) -> void:
	if name == 'TitleScreen':
		ui_layer.hide_back_button()
	else:
		ui_layer.show_back_button()

func _on_UILayer_back_button() -> void:
	ui_layer.hide_message()
	
	stop_game()
	
	if ui_layer.current_screen_name in ['ConnectionScreen', 'MatchScreen']:
		ui_layer.show_screen("TitleScreen")
	elif not Game.online_play:
		ui_layer.show_screen("TitleScreen")
	else:
		ui_layer.show_screen("MatchScreen")

func _on_ReadyScreen_ready_pressed() -> void:
	rpc("player_ready", OnlineMatch.get_my_session_id())

#####
# OnlineMatch callbacks
#####

func _on_OnlineMatch_error(message: String):
	if message != '':
		ui_layer.show_message(message)
	ui_layer.show_screen("MatchScreen")

func _on_OnlineMatch_disconnected():
	#_on_OnlineMatch_error("Disconnected from host")
	_on_OnlineMatch_error('')

func _on_OnlineMatch_player_left(player) -> void:
	ui_layer.show_message(player.username + " has left")
	
#	game.kill_player(player.peer_id)
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
	ready_screen.set_status(session_id, "READY!")

	if get_tree().is_network_server() and not players_ready.has(session_id):
		players_ready[session_id] = true
		if players_ready.size() == OnlineMatch.players.size():
			if OnlineMatch.match_state != OnlineMatch.MatchState.PLAYING:
				OnlineMatch.start_playing()
			start_game()

func start_game() -> void:
	if Game.online_play:
		players = OnlineMatch.get_player_names_by_peer_id()

	game.game_start(players)

func stop_game() -> void:
	OnlineMatch.leave()
	
	players.clear()
	players_ready.clear()
	players_score.clear()
	
	game.game_stop()

func restart_game() -> void:
	stop_game()
	start_game()

func _on_Game_game_started() -> void:
	ui_layer.hide_screen()
	ui_layer.hide_all()
	Game.game_started = true

func _on_Game_player_dead(player_id: int) -> void:
	if Game.online_play:
		var my_id = get_tree().get_network_unique_id()
		if player_id == my_id:
			ui_layer.show_message("You lose!")

func _on_Game_game_over(player_id: int) -> void:
	players_ready.clear()
	
	if not Game.online_play:
		show_winner(players[player_id])
	elif get_tree().is_network_server():
		if not players_score.has(player_id):
			players_score[player_id] = 1
		else:
			players_score[player_id] += 1
		
		var player_session_id = OnlineMatch.get_session_id(player_id)
		var is_match: bool = players_score[player_id] >= 5
		rpc("show_winner", players[player_id], player_session_id, players_score[player_id], is_match)

remotesync func show_winner(name: String, session_id: String = '', score: int = 0, is_match: bool = false) -> void:
	if is_match:
		ui_layer.show_message(name + " WINS THE WHOLE MATCH!")
	else:
		ui_layer.show_message(name + " wins this round!")
	
	yield(get_tree().create_timer(2.0), "timeout")
	if not game.game_started:
		return
	
	if Game.online_play:
		if is_match:
			stop_game()
			ui_layer.show_screen("MatchScreen")
		else:
			ready_screen.hide_match_id()
			ready_screen.reset_status("Waiting...")
			ready_screen.set_score(session_id, score)
			ui_layer.show_screen("ReadyScreen")
	else:
		restart_game()
