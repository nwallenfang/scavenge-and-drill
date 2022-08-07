extends Spatial

export var quest := false

var s
func _ready():
	if quest:
		if FishQuest.stage >= 2:
			queue_free()
		$AnemoneBase.scale *= 1.5
		$AnemoneBase.get_surface_material(0).albedo_color = Color.blueviolet
	s = $AnemoneBase.scale

var dialog := false
var hp := 1.0
var drilled_out := false
func get_drilled(delta):
	if drilled_out:
		return
	if not dialog and not quest:
		dialog = true
		Dialog.trigger("anemone_drill")
	hp -= delta
	$DrillTarget.translation.y = lerp(.45, .8, hp)
	$AnemoneBase.scale = s*lerp(.69, 1.0, hp)
	if hp <= 0.0:
		drilled_out = true
		Game.drill.cooldown()
		$AnemoneBase.visible = false
		$DrillTarget/Area.set_deferred("monitorable", false)
		$DrillTarget/Area.set_deferred("monitoring", false)
		if quest:
			FishQuest.mined_anemone()
