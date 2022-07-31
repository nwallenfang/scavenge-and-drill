extends Spatial

export var amount = 2
export var type = 1
export var label_color: Color

signal picked_up
signal animation_done
func picked_up():
	if is_network_master():

		Game.rpc("sync_treasures", amount, type)

	emit_signal("picked_up")
	self.set_deferred("monitoring", false)
	
	# spawn treasure label3d
	$Label.set_as_toplevel(true)
	$Label.visible = true
	
	# set right color in animation
	var animation: Animation = $AnimationPlayer.get_animation("popup")
	var track_index = animation.find_track("Label:modulate")
	var label_color_blended_out = Color(label_color.r, label_color.g, label_color.b, 0.0)
	animation.track_set_key_value(track_index, 0, label_color)
	animation.track_set_key_value(track_index, 1, label_color_blended_out)
	$Label.modulate = label_color
	$AnimationPlayer.play("popup")
	yield($AnimationPlayer, "animation_finished")

	emit_signal("animation_done")


func _on_TreasureArea_body_entered(body: Node) -> void:
	if body is Player:
		picked_up()
