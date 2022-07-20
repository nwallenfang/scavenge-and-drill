extends Node



var game_started := false
var game_over := false
var players_alive := {}
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
	
	if game_started:
		game_stop()
	
	game_started = true
	game_over = false
	players_alive = players
	
	var player_index := 1
#	for peer_id in players:
##		var other_player = Player.instance()
#		other_player.name = str(peer_id)
#		players_node.add_child(other_player)
#
#		other_player.set_network_master(peer_id)
#		other_player.set_player_name(players[peer_id])
#		other_player.position = map.get_node("PlayerStartPositions/Player" + str(player_index)).position
#		other_player.connect("player_dead", self, "_on_player_dead", [peer_id])
#
#		if not Game.online_play:
#			other_player.player_controlled = true
#			other_player.input_prefix = "player" + str(player_index) + "_"
#
#		player_index += 1
	
	if Game.online_play:
		var my_id := get_tree().get_network_unique_id()
		# Tell the host that we've finished setup.
		rpc_id(1, "_finished_game_setup", my_id)


# Records when each player has finished setup so we know when all players are ready.
mastersync func _finished_game_setup(player_id: int) -> void:
	players_setup[player_id] = players_alive[player_id]
	if players_setup.size() == players_alive.size():
		# Once all clients have finished setup, tell them to start the game.
		rpc("_do_game_start")

# Actually start the game on this client.
remotesync func _do_game_start() -> void:
	emit_signal("game_started")
	get_tree().set_pause(false)


func game_stop() -> void:
	game_started = false

#	for child in players_node.get_children():
#		players_node.remove_child(child)
#		child.queue_free()


func _on_player_dead(player_id) -> void:
	emit_signal("game_over")
