tool
extends Spatial

export var version := 1 setget set_version
func set_version(v):
	version = v
	if Engine.editor_hint:
		for c in get_children():
			c.visible = str(version) in c.name
