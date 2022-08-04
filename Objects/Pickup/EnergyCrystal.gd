extends Spatial

func _on_interaction(actor):
	# TO DO Animation
	
	rpc("remote_delete")
	
var hp := 1.0
func get_drilled(amount):
	hp -= amount
	$Model.scale.y = lerp(.3, 1.0, hp)
	if Game.host and hp <= 0.0:
		Game.rpc("sync_energy_charges", Game.energy_charges + 1.0)
		rpc("drilled_out")

remotesync func drilled_out():
	queue_free()
