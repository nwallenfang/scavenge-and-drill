tool
extends Spatial

export var sync_bones_with_spatials : bool = false setget set_sync

var model_ready := false
func _ready():
	model_ready = true
	self.sync_bones_with_spatials = true

func set_sync(s):
	if model_ready:
		sync_bones_with_spatials = s
		if sync_bones_with_spatials:
			for i in $Skeleton.get_bone_count():
				var bone_transform = $Skeleton.get_bone_pose(i)
				get_node("Bones/" + str(i)).transform = bone_transform

func _process(delta):
	if sync_bones_with_spatials:
		for i in $Skeleton.get_bone_count():
			$Skeleton.set_bone_pose(i, get_node("Bones/" + str(i)).transform)
