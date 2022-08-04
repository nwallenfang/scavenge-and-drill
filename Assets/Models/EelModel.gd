#tool
extends Spatial

export var sync_bones_with_spatials : bool = false setget set_sync

func set_sync(s):
	sync_bones_with_spatials = s
	if sync_bones_with_spatials:
		for i in $Skeleton.get_bone_count():
			var bone_transform = $Skeleton.get_bone_pose(i)
			get_node("Bones/" + str(i)).transform = bone_transform

