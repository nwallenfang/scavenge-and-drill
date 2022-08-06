extends Node


onready var ui: UI  # will be set in level do_game_setup()
onready var dialog_ui

var online_play := true
# debug mode set from command line -> skip cutscenes, main menu, etc.
var debug := false

var host := false

var own_player: Player
var other_player: Player
var roller: Player
var drill: Player

var game_started := false

var viewport_sprite: Sprite
var main_cam: Camera
var level

var main

var mouse_layer: MouseDetectionLayer

var max_power := 100.0
var power := 100.0 setget set_power
var power_loss_per_s := 50.0
var power_loss_per_s_upgraded := 0.5
var power_loss_per_s_default := 1.0 # used to be 10
var power_draining := false

var try_count = 1  # gets increased on restart

var max_energy_charges = 10
var energy_charges: int = 2

const TYPE_GOLD = 1
const TYPE_GEARS = 2
const TYPE_3 = 3

var treasure_gold = 0
var treasure_gears = 0
var treasure_diamond = 0 

var collectibles_node: Node

class Upgrades:
	var chain_longer := false #Done
	var less_power_drain := false #Done
	var more_move_speed := false #Done
	var more_bullet_damage := false #Done
	var position_swap := false
	var super_mode := true
	
class Progress:
	var mined_energy_charges = 0  # doesn't have to equal number of crystals, atm they give 2 charges

var upgrades: Upgrades = Upgrades.new()
var progress: Progress = Progress.new()

func _process(delta: float) -> void:
#	if is_instance_valid(viewport_sprite) and is_instance_valid(main_cam):
#		if viewport_sprite != null:
#			#print(viewport_sprite.material.get("shader_param/ViewportTexture2"))
#			viewport_sprite.material.set_shader_param("sideview_active", main_cam.shader_active)
#			viewport_sprite.material.set_shader_param("sideview_visible", main_cam.shader_visible)
#			viewport_sprite.material.set_shader_param("sideview_direction", main_cam.shader_direction)
	if Input.is_action_just_pressed("pause"):
		ui.toggle_pause()
		
	if Input.is_action_just_pressed("skip_dialog"):
		dialog_ui.rpc("skip_dialog")
	if Input.is_action_just_pressed("disable_power"):
		rpc("disable_power")
	if Input.is_action_just_pressed("add_energy"):
		rpc("sync_energy_charges", (energy_charges + 1))
		rpc("sync_treasures", 100, 1)
		rpc("sync_treasures", 100, 2)
	if Input.is_action_just_pressed("remove_energy"):
		rpc("sync_energy_charges", (energy_charges - 1))
	if Input.is_action_just_pressed("go_to_shop"):
		level.rpc("power_depleted")
	if power_draining and game_started:  # state machine maybe? menu/in_game/merchant
		# this doesn't get synced at the moment since the calc should be the
		# same for both players
		# maybe sync every x seconds to make sure
		self.power -= power_loss_per_s * delta

signal power_depleted
var power_critical_threshold = 0.4 * max_power
signal power_low  # maybe some screen effect or sound? maybe not
signal power_filled
func set_power(value: float):
	if power >= power_critical_threshold and value < power_critical_threshold:
		emit_signal("power_low")
		Dialog.trigger("power_low")
	if value <= 0.0 and power > 0.0:
		emit_signal("power_depleted")
	
	power = value
	if ui != null:
		ui.set_power(value)

remotesync func disable_power():
	power_loss_per_s = 0.0

remotesync func sync_treasures(amount, type):
	match type:
		TYPE_GOLD:
			treasure_gold += amount
		TYPE_GEARS:
			treasure_gears += amount
		TYPE_3:
			treasure_diamond += amount
			
	ui.update_treasures(type)


remotesync func sync_energy_charges(x: int):
	if x > energy_charges:
		progress.mined_energy_charges += x - energy_charges
	if x > max_energy_charges:
		x = max_energy_charges
	energy_charges = x
	ui.set_energy_charges(x)


signal treasure_count_changed
remotesync func set_upgrade(name, cost_gold, cost_gears):
	# only set Upgrades with this method so that it's nice and synced
	Game.log("setting upgrade " + name)
	treasure_gears -= cost_gears
	treasure_gold -= cost_gold
	
	upgrades.set(name, true)
	
	emit_signal("treasure_count_changed")


func log(msg: String):
	print(msg)
	if ui != null:
		ui.add_to_log(msg)

var player_1_wants_to_swap := false
var player_2_wants_to_swap := false
remotesync func try_swap(player_name):
	if not upgrades.position_swap:
		return
	if "1" in player_name:
		Game.roller.get_node("TeleportEffect").try()
		if player_2_wants_to_swap:
			execute_swap()
		elif not player_1_wants_to_swap:
			player_1_wants_to_swap = true
			Game.log("Player 1 wants to swap")
			yield(get_tree().create_timer(2.0), "timeout")
			player_1_wants_to_swap = false
	elif "2" in player_name:
		Game.drill.get_node("TeleportEffect").try()
		if player_1_wants_to_swap:
			execute_swap()
		elif not player_2_wants_to_swap:
			player_2_wants_to_swap = true
			Game.log("Player 2 wants to swap")
			yield(get_tree().create_timer(2.0), "timeout")
			player_2_wants_to_swap = false

func execute_swap():
	# Todo Animation
	Game.log("SWAP!")
	rpc("sync_energy_charges", Game.energy_charges-2)
	player_1_wants_to_swap = false
	player_2_wants_to_swap = false
	roller.static_mode = true
	drill.static_mode = true
	roller.get_node("TeleportEffect").start()
	drill.get_node("TeleportEffect").start()
	yield(get_tree().create_timer(1.0),"timeout")
	var player1_pos = roller.global_translation
	var player2_pos = drill.global_translation
	roller.global_translation.x = player2_pos.x
	roller.global_translation.z = player2_pos.z
	drill.global_translation.x = player1_pos.x
	drill.global_translation.z = player1_pos.z
	yield(get_tree().create_timer(.8),"timeout")
	roller.static_mode = false
	drill.static_mode = false

func execute_contract(static_mode_after = false):
	Game.log("CONTRACT!")
	roller.static_mode = true
	drill.static_mode = true
	yield(get_tree().create_timer(.5),"timeout")
	var tween = get_tree().create_tween()
	tween.tween_property(drill, "global_2d", roller.global_2d, 1.0)
	yield(get_tree().create_timer(2.5),"timeout")
	roller.static_mode = static_mode_after
	drill.static_mode = static_mode_after

var super_mode := false
var super_speed := 55.0
var super_duration := 8.0
func execute_super_mode():
	Game.log("Super mode!")
	rpc("sync_energy_charges", Game.energy_charges-2)
	yield(execute_contract(), "completed")
	Game.log("Contract Done")
	super_mode = true
	drill.mounted = true
	var old_speed := roller.ACC
	roller.ACC = super_speed
	roller.cable_factor = 0.0
	roller.get_node("MagicForceField").visible = true
	yield(get_tree().create_timer(super_duration),"timeout")
	roller.get_node("MagicForceField").visible = false
	drill.mounted = false
	roller.ACC = old_speed
	roller.cable_factor = 1.0
	super_mode = false

var player_1_wants_to_super := false
var player_2_wants_to_super := false
remotesync func try_super(player_name):
	if not upgrades.super_mode:
		return
	if "1" in player_name:
		if player_2_wants_to_super:
			execute_super_mode()
		elif not player_1_wants_to_super:
			player_1_wants_to_super = true
			Game.log("Player 1 wants to super")
			yield(get_tree().create_timer(2.0), "timeout")
			player_1_wants_to_super = false
	elif "2" in player_name:
		if player_1_wants_to_super:
			execute_super_mode()
		elif not player_2_wants_to_super:
			player_2_wants_to_super = true
			Game.log("Player 2 wants to super")
			yield(get_tree().create_timer(2.0), "timeout")
			player_2_wants_to_super = false

func not_enough_crystals():
	ui.show_energy_crystals_missing()
