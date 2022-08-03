extends Spatial
class_name InteractObject

const OUTLINE_BLUE = preload("res://Assets/Materials/outline_blue.tres")
const OUTLINE_RED = preload("res://Assets/Materials/outline_red.tres")
const OUTLINE_BOTH = preload("res://Assets/Materials/two_outlines.tres")

export var limit_to_player := 0

var mesh_instances := []

func fetch_mesh_instances():
	for c in $Model.get_children():
		if c is MeshInstance:
			mesh_instances.append(c)

func _ready():
	fetch_mesh_instances()

func disable():
	$Area.queue_free()
	remove_from_group("networked")

var hovering_actor_names = []
var something_has_changed := false
func set_hover_state(active: bool, actor_name):
	if active:
		if not actor_name in hovering_actor_names:
			hovering_actor_names.append(actor_name)
			something_has_changed = true
	else:
		if actor_name in hovering_actor_names:
			hovering_actor_names.erase(actor_name)
			something_has_changed = true
	update_hover_outline()

func _network_process(delta):
	if something_has_changed:
		rpc_unreliable("append_hovering_actor_names", hovering_actor_names)
		something_has_changed = false

remote func append_hovering_actor_names(han):
	if Game.other_player.name in han:
		if not Game.other_player.name in hovering_actor_names:
			hovering_actor_names.append(Game.other_player.name)
	else:
		hovering_actor_names.erase(Game.other_player.name)
	update_hover_outline()

func update_hover_outline():
	for mi in mesh_instances:
		if len(hovering_actor_names) == 0:
			mi.get_surface_material(0).next_pass = null
		elif len(hovering_actor_names) == 2 and limit_to_player == 0:
			mi.get_surface_material(0).next_pass = OUTLINE_BOTH
		elif "1" in hovering_actor_names[0] and limit_to_player != 2:
			mi.get_surface_material(0).next_pass = OUTLINE_BLUE
		elif "2" in hovering_actor_names[0] and limit_to_player != 1:
			mi.get_surface_material(0).next_pass = OUTLINE_RED
		else:
			mi.get_surface_material(0).next_pass = null

func on_interaction(actor):
	_on_interaction(actor)

func _on_interaction(actor): 
	pass # OVERRIDE THIS

remotesync func remote_delete():
	queue_free()
