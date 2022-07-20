extends KinematicBody2D

onready var player_name_label := $NameRect/NameLabel
onready var hit_box = $HitBox
onready var animation_player := $AnimationPlayer

export (bool) var player_controlled := false
export (String) var input_prefix := "player1_"

var speed := 400.0

signal player_dead ()

func set_player_name(player_name: String) -> void:
	player_name_label.text = player_name

func attack() -> void:
	for body in hit_box.get_overlapping_bodies():
		if body == self:
			continue
		if body.has_method("hurt"):
			body.hurt()

func hurt() -> void:
	if not GameState.online_play:
		die()
	elif is_network_master():
		rpc("die")

remotesync func die() -> void:
	# Add what you want to happen in your game when a player dies.
	queue_free()
	emit_signal("player_dead")

func _physics_process(delta: float) -> void:
	if player_controlled:
		var vector = Vector2(
			Input.get_action_strength(input_prefix + "right") - Input.get_action_strength(input_prefix + "left"),
			Input.get_action_strength(input_prefix + "down") - Input.get_action_strength(input_prefix + "up")).normalized()
		vector *= (speed * delta)
		move_and_collide(vector)
		
		var is_attacking: bool = not animation_player.is_playing() and Input.is_action_just_pressed(input_prefix + "attack")
		if is_attacking:
			animation_player.play("Attack")
		
		if GameState.online_play:
			rpc("update_remote_player", global_position, is_attacking)

# Extremely naive position and animation sync'ing.
#
# This will work locally, and under ideal network conditions, but likely won't 
# be acceptable over the live internet for a large percentage of users.
#
# You'll need to replace this with more efficient sync'ing mechanism, which
# could include input prediction, rollback, limiting how often sync'ing happens
# or any other number of techniques.
#
# In addition to that, you'll also need to expand the number of things that are
# sync'd, depending on the needs of your game.
puppet func update_remote_player(_position: Vector2, is_attacking: bool) -> void:
	global_position = _position
	
	if is_attacking and not animation_player.is_playing():
		animation_player.play("Attack")
