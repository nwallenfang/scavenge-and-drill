extends Spatial

func _on_interaction(actor):
	# TO DO Animation
	
	rpc("remote_delete")
	
var hp := 1.0
func get_drilled(amount):
	hp -= amount * 1.8
	$Model.scale.y = lerp(.3, 1.0, hp)
	if Game.host and hp <= 0.0:
		Game.rpc("sync_energy_charges", Game.energy_charges + 2.0)
		rpc("drilled_out")

const CRYSTAL_POP = preload("res://Effects/CrystalPop.tscn")

remotesync func drilled_out():
	Sound.get_node("CrystalMined").play()
	var pop = CRYSTAL_POP.instance()
	Game.level.add_child(pop)
	pop.global_translation = self.global_translation
	queue_free()
