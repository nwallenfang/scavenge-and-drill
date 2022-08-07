extends Spatial

func open():
	$AnimationPlayer.play("open")

func close():
	yield(get_tree().create_timer(1.0),"timeout")
	$AnimationPlayer.play("close")

var currently_drilled := false
var hp := 1.0
var drilled_out := false
func get_drilled(delta):
	if drilled_out:
		return
	currently_drilled = true
	hp -= delta
	$DrillTarget.translation.z = lerp(.68, 1.2, hp)
#	if not $DrillParticles.emitting:
#		$DrillParticles.emitting = true
	if hp <= 0.0:
		drilled_out = true
		Game.drill.cooldown()
		$Pivot.visible = false
		#$TreasureArea.picked_up()
		$DrillTarget/Area.set_deferred("monitorable", false)
		$DrillTarget/Area.set_deferred("monitoring", false)
		open()
		Dialog.trigger("game_won")
		yield(get_tree().create_timer(5),"timeout")
		Game.play_end()

#func _physics_process(delta):
#	if currently_drilled:
#		if not Game.drill.is_drilling:
#			currently_drilled = false
#			$DrillParticles.emitting = false
		
