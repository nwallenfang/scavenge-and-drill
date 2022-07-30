extends Node


onready var ui: UI  # will be set in level do_game_setup()

var online_play := true
# debug mode set from command line -> skip cutscenes, main menu, etc.
var debug := false

var own_player: Player
var other_player: Player

var game_started := false

var viewport_sprite: Sprite
var main_cam: Camera

var max_o2 := 100.0
var o2 := 100.0 setget set_o2
var o2_loss_per_s := 20.0

const TYPE_GOLD = 1
const TYPE_GEARS = 2
const TYPE_3 = 3

var treasure_gold = 1
var treasure_gears = 1
var treasure_3 = 0 

class Upgrades:
	var chain_longer := false

var upgrades: Upgrades = Upgrades.new()

func _process(delta: float) -> void:
#	if is_instance_valid(viewport_sprite) and is_instance_valid(main_cam):
#		if viewport_sprite != null:
#			#print(viewport_sprite.material.get("shader_param/ViewportTexture2"))
#			viewport_sprite.material.set_shader_param("sideview_active", main_cam.shader_active)
#			viewport_sprite.material.set_shader_param("sideview_visible", main_cam.shader_visible)
#			viewport_sprite.material.set_shader_param("sideview_direction", main_cam.shader_direction)
	if Input.is_action_just_pressed("pause"):
		ui.toggle_pause()
	if game_started:  # state machine maybe? menu/in_game/merchant
		# this doesn't get synced at the moment since the calc should be the
		# same for both players
		# maybe sync every x seconds to make sure
		self.o2 -= o2_loss_per_s * delta

signal oxygen_depleted
var oxy_critical_threshold = 0.1 * max_o2
signal oxygen_critical  # maybe some screen effect or sound? maybe not
signal oxygen_filled
func set_o2(value: float):
	if o2 >= oxy_critical_threshold and value < oxy_critical_threshold:
		emit_signal("oxygen_critical")
	if value <= 0.0 and o2 > 0.0:
		emit_signal("oxygen_depleted")
	
	o2 = value
	ui.set_o2(value)


remotesync func sync_treasures(amount, type):
	match type:
		TYPE_GOLD:
			treasure_gold = amount
		TYPE_GEARS:
			treasure_gears = amount
		TYPE_3:
			treasure_3 = amount

	ui.set_treasure(amount, type)

func set_treasures(amount: int, type: int):
	# maybe this RPC isn't even needed since the treasure gets picked up 
	# for both players..
	if is_network_master():
		rpc("sync_treasures", amount)
		
func set_gold(amount: int):
	pass
	
remotesync func set_upgrade(name, cost_gold, cost_gears):
	# only set Upgrades with this method so that it's nice and synced
	Game.log("setting upgrade " + name)
	treasure_gears -= cost_gears
	treasure_gold -= cost_gold


func log(msg: String):
	print(msg)
	if ui != null:
		ui.add_to_log(msg)
