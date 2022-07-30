extends ViewportContainer

func _ready() -> void:
	pass

var water_dist = preload("res://Assets/Shader/WaterDistortion.gdshader")
func enable_water_distortion():
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = water_dist
	self.material = mat

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
