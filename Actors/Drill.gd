extends Player

func transform_lerp(a:Transform,b:Transform,x:float):
	var scale = a.basis.get_scale() # Das ist wieder so unglaublich peinlich holy shit
	var base := a.basis.orthonormalized().slerp(b.basis.orthonormalized(), x)
	var origin = lerp(a.origin, b.origin, x)
	return Transform(base.scaled(scale), origin)

export var move_acc_default := 8.0
export var move_acc_upgraded := 12.0
export var move_acc_drilling := 4.0

onready var handle := $Model/DrillModel/Handle

var mounted := false setget set_mounted

func set_mounted(m):
	mounted = m

var wants_to_drill := false
var is_drilling := false
var drill_animation_offset := 0.0
var drill_animation_length := .7
var drill_offset_trigger := .9
var last_frame_offset := 0.0

export var ground_color := Color.brown
export var crystal_color := Color.pink
func _ready():
	$Model/GroundParticles.draw_pass_1.surface_get_material(0).set("albedo_color", ground_color)
	$Model/CrystalParticles.draw_pass_1.surface_get_material(0).set("albedo_color", crystal_color)
	

func _physics_process(delta):
	if mounted:
		self.global_2d = Game.roller.global_2d
	else:
		._physics_process(delta)
		if controlled:
			if Input.is_action_just_pressed("initiate_swap"):
				Game.rpc("try_swap", name)
			if Input.is_action_just_pressed("super_mode"):
				Game.rpc("try_super", name)
			if Input.is_action_pressed("shoot") != wants_to_drill:
				rpc("set_drill_want", Input.is_action_pressed("shoot"))
	
		drill_animation_offset += (delta if wants_to_drill else -delta) / drill_animation_length
		drill_animation_offset = clamp(drill_animation_offset, 0.0, 1.0)
		is_drilling = drill_animation_offset > drill_offset_trigger
		if drill_animation_offset != last_frame_offset:
			update_drill_animation()
			last_frame_offset = drill_animation_offset
		if is_drilling:
			drill_the_crystals(delta)
			$Model/GroundParticles.emitting = $DrillArea.get_overlapping_areas().empty()
			$Model/CrystalParticles.emitting = not $DrillArea.get_overlapping_areas().empty()
		else:
			$Model/GroundParticles.emitting = false
			$Model/CrystalParticles.emitting = false

func _network_process(delta):
	._network_process(delta)

remotesync func set_drill_want(b):
	wants_to_drill = b


func update_drill_animation():
	$Model/DrillModel.transform = transform_lerp($Model/Default.transform, $Model/DrillPos.transform, drill_animation_offset)
	


func drill_the_crystals(delta):
	for area in $DrillArea.get_overlapping_areas():
		area.get_parent().get_drilled(delta * .3)
