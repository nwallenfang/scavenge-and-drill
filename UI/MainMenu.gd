extends Control

onready var lobby_code: TextEdit  = $VBoxContainer/HBoxContainer/RightMenu/HBoxContainer/CodeText


func _on_EnterRandomMatchmaking_pressed() -> void:
	Network.connect_to_matchmaking()
	# wait until match is found to make menu invisible.. maybe even once the game is setup
	self.visible = false
	
	



func _on_CreateLobby_pressed() -> void:
	pass # Replace with function body.


func _on_JoinLobby_pressed() -> void:
	var match_id = lobby_code.text.strip_edges()
	if match_id == '':
		print("Need to paste Match ID to join, PUT THIS INTO UI")
		return
	if not match_id.ends_with('.'):
		match_id += '.'
	
	OnlineMatch.join_match(Network.nakama_socket, match_id)
