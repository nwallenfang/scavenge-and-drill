extends Spatial

var currently_drilled := false
var hp := 1.0
var drilled_out := false
func get_drilled(delta):
	if drilled_out:
		return
	currently_drilled = true
	hp -= delta
	$DrillTarget.translation.y = lerp(1.5, 2.1, hp)
	$Pivot.scale = Vector3.ONE * lerp(.9, 1.0, hp)
	if not $DrillParticles.emitting:
		$DrillParticles.emitting = true
	if hp <= 0.0:
		Dialog.trigger("diamond_drilled")
		drilled_out = true
		Game.drill.cooldown()
		$Pivot.visible = false
		$TreasureArea.picked_up()
		$DrillTarget/Area.set_deferred("monitorable", false)
		$DrillTarget/Area.set_deferred("monitoring", false)

func _physics_process(delta):
	if currently_drilled:
		if not Game.drill.is_drilling:
			currently_drilled = false
			$DrillParticles.emitting = false
		
