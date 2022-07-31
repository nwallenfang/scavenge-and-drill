extends Spatial


onready var camera = $Pivot/TopdownCamera

export var player1_color: Color
export var player2_color: Color

func _ready():
	$Player1.set_color(player1_color)
	$Player2.set_color(player2_color)
	$Cable.create_cable($Player1/Handle, $Player2/Handle)
	$Cable.set_players($Player1, $Player2)
	Game.connect("oxygen_depleted", self, "server_oxy_depleted")


func server_oxy_depleted():
	# take care that this doesn't get called twice!
	# (from client and server)
	if is_network_master():
		rpc("oxygen_depleted")

remotesync func oxygen_depleted():
	# TODO play some kind of return cut-scene
	# TODO merchant sequence
	# wait for start click
	# then reset players to their position
	Game.log("OXYGEN DEPLETED")


func do_game_setup(players: Dictionary):
	Game.ui = $UI
	if Game.debug:
		$UI.toggle_dev_panel()
	Network.start()
	
	var id_other_player = 1 if get_tree().get_network_unique_id() == 2 else 2

	Game.main_cam = camera   # $Viewport/DualSideviewCamera
#	Game.main_cam.boss = true
#	Game.viewport_sprite.material.set_shader_param("ViewportTexture1", $Viewport.get_texture())
#	Game.viewport_sprite.material.set_shader_param("ViewportTexture2", $ViewportPartner.get_texture())
	#print(Game.viewport_sprite.material.get("shader_param/ViewportTexture2"))
	
	# TODO instance Level
	
	if not get_tree().is_network_server():
		$Player2.set_network_master(get_tree().get_network_unique_id())
		$Player2.controlled = true
		Game.own_player = $Player2
		Game.other_player = $Player1
		$Player1.set_network_master(id_other_player)
#		$Viewport/DualSideviewCamera.initialize($Player2, $ViewportPartner/DualSideviewCamera)
#		$ViewportPartner/DualSideviewCamera.initialize($Player1, $Viewport/DualSideviewCamera)
		camera.initialize($Player2)
	else:
		$Player1.set_network_master(get_tree().get_network_unique_id())
		$Player1.controlled = true
		Game.own_player = $Player1
		Game.other_player = $Player2
		$Player2.set_network_master(id_other_player)
#		$Viewport/DualSideviewCamera.initialize($Player1, $ViewportPartner/DualSideviewCamera)
#		$ViewportPartner/DualSideviewCamera.initialize($Player2, $Viewport/DualSideviewCamera)
		camera.initialize($Player1)


func _on_RopeLengthChecker_timeout() -> void:
	pass # Replace with function body.
