extends Control

onready var lobby_code: TextEdit  = $VBoxContainer/HBoxContainer/RightMenu/HBoxContainer/CodeText



func _ready() -> void:
	$Buttons.visible = true

func _on_EnterRandomMatchmaking_pressed() -> void:
	Network.connect_to_matchmaking()
	# wait until match is found to make menu invisible.. maybe even once the game is setup
	self.visible = false
	
	


func _on_JoinLobby_pressed() -> void:
	var match_id = lobby_code.text.strip_edges()
	if match_id == '':
		print("Need to paste Match ID to join, PUT THIS INTO UI")
		return
	if not match_id.ends_with('.'):
		match_id += '.'
	
	OnlineMatch.join_match(Network.nakama_socket, match_id)


func _on_PlayWithFriendButton_clicked() -> void:
	print("play with friend")
	$Buttons.visible = false
	$LobbyScreen.visible = true


func _on_PlayWithRandomButton_clicked() -> void:
	print("play with random")
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
	$LobbyScreen.visible = false
	$JoinLobbyScreen.visible = true


func _on_CreateLobby_clicked() -> void:
	$LobbyScreen.visible = false
	$CreateLobbyScreen.visible = true
