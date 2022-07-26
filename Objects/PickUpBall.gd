extends Spatial

const OUTLINE_BLUE = preload("res://Assets/Materials/outline_blue.tres")
const OUTLINE_RED = preload("res://Assets/Materials/outline_red.tres")
const OUTLINE_BOTH = preload("res://Assets/Materials/two_outlines.tres")

func disable():
	$Area.queue_free()
	remove_from_group("networked")

var hovering_actor_names = []
func set_hover_state(active: bool, actor_name):
	if active:
		if not actor_name in hovering_actor_names:
			hovering_actor_names.append(actor_name)
	else:
		if actor_name in hovering_actor_names:
			hovering_actor_names.erase(actor_name)
	update_hover_outline()

func _network_process(delta):
	rpc_unreliable("append_hovering_actor_names", hovering_actor_names)

remote func append_hovering_actor_names(han):
	if Game.other_player.name in han:
		if not Game.other_player.name in hovering_actor_names:
			hovering_actor_names.append(Game.other_player.name)
	else:
		hovering_actor_names.erase(Game.other_player.name)
	update_hover_outline()

func update_hover_outline():
	if len(hovering_actor_names) == 0:
		$MeshInstance.get_surface_material(0).next_pass = null
	elif len(hovering_actor_names) == 2:
		$MeshInstance.get_surface_material(0).next_pass = OUTLINE_BOTH
	elif "1" in hovering_actor_names[0]:
		$MeshInstance.get_surface_material(0).next_pass = OUTLINE_BLUE
	else:
		$MeshInstance.get_surface_material(0).next_pass = OUTLINE_RED

func on_interact(actor):
	actor.inventory_ball_count += 1
	actor.update_ball_count()
	rpc("remote_delete")

remotesync func remote_delete():
	queue_free()
