extends ViewportContainer

func _ready() -> void:
	pass

var water_dist = preload("res://Assets/Shader/WaterDistortion.gdshader")
func enable_water_distortion():
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = water_dist
	self.material = mat
	
var post_proc = preload("res://Assets/Shader/PostProcessing.gdshader")
func enable_post_processing():
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = post_proc
	self.material = mat
