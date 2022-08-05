extends Spatial

var currently_drilled := false
var hp := 1.0
var drilled_out := false
var old_scale_y

func _ready():
	old_scale_y = $Wall.scale.y

func get_drilled(delta):
	if drilled_out:
		return
	currently_drilled = true
	hp -= delta
	#$DrillTarget.translation.y = lerp(1.5, 2.1, hp)
	$Wall.scale.y = old_scale_y * lerp(.82, 1.0, hp)
	if not $DrillParticles.emitting:
		$DrillParticles.emitting = true
	if hp <= 0.0:
		drilled_out = true
		Game.drill.cooldown()
		$Wall.visible = false
		$StaticBody.queue_free()

func _physics_process(delta):
	if currently_drilled:
		if not Game.drill.is_drilling:
			currently_drilled = false
			$DrillParticles.emitting = false
		
