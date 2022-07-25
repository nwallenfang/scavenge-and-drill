extends Spatial

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
		$MeshInstance.get_surface_material(0).next_pass = load("res://Assets/Materials/two_outlines.tres")
	elif "1" in hovering_actor_names[0]:
		$MeshInstance.get_surface_material(0).next_pass = load("res://Assets/Materials/outline_blue.tres")
	else:
		$MeshInstance.get_surface_material(0).next_pass = load("res://Assets/Materials/outline_red.tres")

func on_interact(actor):
	pass
