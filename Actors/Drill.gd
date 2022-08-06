extends Player

func transform_lerp(a:Transform,b:Transform,x:float):
	var scale = a.basis.get_scale() # Das ist wieder so unglaublich peinlich holy shit
	var base := a.basis.orthonormalized().slerp(b.basis.orthonormalized(), x)
	var origin = lerp(a.origin, b.origin, x)
	return Transform(base.scaled(scale), origin)

export var move_acc_default := 8.0
export var move_acc_upgraded := 12.0
export var move_acc_drilling := 4.0
export var move_acc_drilling_target := 0.0

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

var has_drill_target := false
var drill_target
var drill_cooldown := false

export var ground_color := Color.brown
export var crystal_color := Color.pink
export var gold_color := Color.gold
export var scrap_color := Color.gray

func _ready():
	._ready()
	$Model/GroundParticles.scale *= (1.2 if Game.upgrades.drill_power else .8)
	$Model/CrystalParticles.scale *= (1.2 if Game.upgrades.drill_power else .8)
	$Model/GoldParticles.scale *= (1.2 if Game.upgrades.drill_power else .8)
	$Model/ScrapParticles.scale *= (1.2 if Game.upgrades.drill_power else .8)
	$Model/GroundParticles.draw_pass_1.surface_get_material(0).set("albedo_color", ground_color)
	$Model/CrystalParticles.draw_pass_1.surface_get_material(0).set("albedo_color", crystal_color)
	$Model/GoldParticles.draw_pass_1.surface_get_material(0).set("albedo_color", gold_color)
	$Model/ScrapParticles.draw_pass_1.surface_get_material(0).set("albedo_color", scrap_color)
	var color = Color.red if Game.upgrades.drill_power else $Model/DrillModel/DrillShader.get("material/0").get("shader_param/albedo")
	color.a = 0.0
	$Model/DrillModel/DrillShader.get("material/0").set("shader_param/albedo", color)
	

func _physics_process(delta):
	if mounted:
		self.global_2d = Game.roller.global_2d
	else:
		._physics_process(delta)
		if controlled:
			if Input.is_action_just_pressed("initiate_swap"):
				if Game.energy_charges >= 2:
					Game.rpc("try_swap", name)
				else:
					Game.not_enough_crystals()
			if Input.is_action_just_pressed("super_mode"):
				if Game.energy_charges >= 2:
					Game.rpc("try_super", name)
				else:
					Game.not_enough_crystals()
			if drill_cooldown:
				if wants_to_drill:
					rpc("set_drill_want", false)
			elif Input.is_action_pressed("shoot") != wants_to_drill:
				rpc("set_drill_want", Input.is_action_pressed("shoot"))
	
	if mounted or static_mode:
		wants_to_drill = false
	if wants_to_drill and drill_animation_offset == 0.0:
		has_drill_target = not $TargetDetection.get_overlapping_areas().empty()
		if has_drill_target:
			drill_target = $TargetDetection.get_overlapping_areas()[0].get_parent()
			ACC = move_acc_drilling_target
	if has_drill_target and not wants_to_drill:
		ACC = move_acc_default if not Game.upgrades.more_move_speed else move_acc_upgraded
	drill_animation_offset += (delta if wants_to_drill else -delta) / drill_animation_length
	drill_animation_offset = clamp(drill_animation_offset, 0.0, 1.0)
	is_drilling = drill_animation_offset > drill_offset_trigger
	if drill_animation_offset != last_frame_offset or has_drill_target:
		update_drill_sound()
		update_drill_animation()
		last_frame_offset = drill_animation_offset
	if not has_drill_target:
		if is_drilling:
			ACC = move_acc_drilling
			drill_the_crystals(delta)
			$Model/GroundParticles.emitting = $DrillArea.get_overlapping_areas().empty()
			$Model/CrystalParticles.emitting = false
			$Model/GoldParticles.emitting = false
			$Model/ScrapParticles.emitting = false
			for a in $DrillArea.get_overlapping_areas():
				if "Crystal" in a.get_parent().name:
					$Model/CrystalParticles.emitting = true
				elif "Gold" in a.get_parent().name:
					$Model/GoldParticles.emitting = true
				elif "Gear" in a.get_parent().name:
					$Model/ScrapParticles.emitting = true
		else:
			ACC = move_acc_default if not Game.upgrades.more_move_speed else move_acc_upgraded
			$Model/GroundParticles.emitting = false
			$Model/CrystalParticles.emitting = false
			$Model/GoldParticles.emitting = false
			$Model/ScrapParticles.emitting = false
	else:
		if is_drilling:
			drill_the_crystals(delta)

func _network_process(delta):
	._network_process(delta)

remotesync func set_drill_want(b):
	wants_to_drill = b

var sound := false
func update_drill_sound():
	if drill_animation_offset > .3:
		if not sound:
			sound = true
			Sound.start_drilling()
	else:
		if sound:
			sound = false
			Sound.stop_drilling()

func update_drill_animation():
	if not has_drill_target:
		$Model/DrillModel.transform = transform_lerp($Model/Default.transform, $Model/DrillPos.transform, drill_animation_offset)
	else:
		$Model/DrillModel.global_transform = transform_lerp($Model/Default.global_transform, drill_target.get_node("DrillModel").global_transform, drill_animation_offset)
	var color = $Model/DrillModel/DrillShader.get("material/0").get("shader_param/albedo")
	color.a = drill_animation_offset
	$Model/DrillModel/DrillShader.get("material/0").set("shader_param/albedo", color)


func drill_the_crystals(delta):
	if has_drill_target:
		drill_target.get_parent().get_drilled(delta * .37 * (1.2 if Game.upgrades.drill_power else .8))
	for area in $DrillArea.get_overlapping_areas():
		area.get_parent().get_drilled(delta * .3)

func cooldown():
	drill_cooldown = true
	yield(get_tree().create_timer(drill_animation_length + 1.5),"timeout")
	drill_cooldown = false

func try_particles_red():
	$TryParticles.restart()
	$TryParticles.emitting = true
