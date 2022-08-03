extends InteractObject

func _on_interaction(actor):
	# TO DO Animation
	Game.rpc("sync_energy_charges", Game.energy_charges + 1)
	rpc("remote_delete")
	
