extends Control

signal match_made


func _ready() -> void:
	$Buttons.visible = true
	OnlineMatch.connect("matchmaker_matched", self, "_on_OnlineMatch_matchmaker_matched")
	OnlineMatch.connect("match_created", self, "_on_OnlineMatch_created")
	OnlineMatch.connect("match_joined", self, "_on_OnlineMatch_joined")
	OnlineMatch.connect("player_joined", self, "_on_OnlineMatch_player_joined")
	OnlineMatch.connect("match_ready", self, "_on_OnlineMatch_match_ready")
	Game.ui = get_parent().get_node("UI")
	Sound.start_main_menu_theme()

func _on_EnterRandomMatchmaking_pressed() -> void:
	Network.connect_to_matchmaking()
	# wait until match is found to make menu invisible.. maybe even once the game is setup
	self.visible = false
	
	


func _on_OnlineMatch_matchmaker_matched(_players: Dictionary):
	print("matchmaker matched")
	



func _on_OnlineMatch_created(match_id: String):
	print("Match created")
	$"%CreateLobbyID".text = match_id
	

func _on_OnlineMatch_joined(match_id: String):
	print("Match joined")
	$"%JoinedSuccess".visible = true
	emit_signal("match_made")



func _on_PlayWithFriendButton_clicked() -> void:
	$Buttons.visible = false
	$LobbyScreen.visible = true


func _on_PlayWithRandomButton_clicked() -> void:
	Sound.get_node("ClickSound").play()
	Network.connect_to_matchmaking()
	# wait until match is found to make menu invisible.. maybe even once the game is setup
	$Buttons.visible = false
	$MatchmakingScreen.visible = true
	$ProgressAnimator.start()


var dots = 2
func _on_ProgressAnimator_timeout() -> void:
	var dots_string
	if dots == 1:
		dots_string = "."
	elif dots == 2:
		dots_string = ".."
	else:
		dots_string = "..."
	dots += 1
	dots %= 3
	
	$"%Looking".text = "Looking for a player" + dots_string


func _on_JoinLobby_clicked() -> void:
	Sound.get_node("ClickSound").play()
	$LobbyScreen.visible = false
	$JoinLobbyScreen.visible = true


func _on_CreateLobby_clicked() -> void:
	Sound.get_node("ClickSound").play()
	Network.connect_to_nakama()
	yield(Network, "socket_connected")	
	OnlineMatch.create_match(Network.nakama_socket)
	$LobbyScreen.visible = false
	$CreateLobbyScreen.visible = true


func _on_CopyButton_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		
		if event.pressed:
			print("copy")
			OS.clipboard = $"%CreateLobbyID".text
			$"%CodeCopied".text = "Code copied!"
			yield(get_tree().create_timer(2.5), "timeout")
			$"%CodeCopied".text = ""


func _on_EnterLobbyButton_clicked() -> void:
	print("ENTER LOBBY")
	var match_id = $"%JoinLobbyID".text.strip_edges()
	Network.connect_to_nakama()
	yield(Network, "socket_connected")	
	OnlineMatch.join_match(Network.nakama_socket, match_id)
	
	
func _on_OnlineMatch_player_joined(player) -> void:
	pass

#func _on_OnlineMatch_player_left(player) -> void:
#	remove_player(player.session_id)

func _on_OnlineMatch_player_status_changed(player, status) -> void:
	print("status changed")

func _on_OnlineMatch_match_ready(_players: Dictionary) -> void:
	emit_signal("match_made")


func _on_SettingsButton_clicked() -> void:
	Game.ui.toggle_pause()


# Lobby Screen
func _on_Back_clicked() -> void:
	$Buttons.visible = true
	$LobbyScreen.visible = false


func _on_BackLobby_clicked() -> void:
	$JoinLobbyScreen.visible = false
	$LobbyScreen.visible = true


func _on_BackCreatedLobby_clicked() -> void:
	get_tree().reload_current_scene()	
	$CreateLobbyScreen.visible = false
	$LobbyScreen.visible = true


func _on_Cancel_pressed() -> void:
	OnlineMatch.leave()
	get_tree().reload_current_scene()


func _on_CreditsButton_clicked() -> void:
	get_parent().get_node("Credits").play_credits()
