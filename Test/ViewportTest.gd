extends Spatial

var viewport1
var viewport2
var sprite

func _ready():
	viewport1 = $Level/Viewport1
	viewport2 = $Level/Viewport2
	sprite = $Sprite
	#viewport2.world = viewport1.world
	sprite.material.set_shader_param("ViewportTexture1", viewport1.get_texture())
	sprite.material.set_shader_param("ViewportTexture2", viewport2.get_texture())
