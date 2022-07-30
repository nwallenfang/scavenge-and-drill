extends RigidBody

var target : Spatial setget set_target

func set_target(t: Spatial):
	target = t
	self.global_translation = target.global_translation

func _physics_process(delta):
	if target != null:
		self.global_translation = target.global_translation
