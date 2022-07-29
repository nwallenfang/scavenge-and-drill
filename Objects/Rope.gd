extends Spatial

export var number_of_segments: int  # > 1 (obv)
export var start: NodePath
export var end: NodePath
export var segment_offset: Vector2  # for debugging mainly


const ROPE_SEGMENT = preload("res://Objects/RopeSegment.tscn")
func _ready() -> void:
	var start_node := get_node(start)
	var end_node := get_node(end)
	var start_pos = start_node.global_translation
	var end_pos = end_node.global_translation
	# generate segments
	var beginning_joint = HingeJoint.new()
	var prev_joint: HingeJoint = beginning_joint
	var joint: HingeJoint = null
	var segment: RopeSegment = null

	beginning_joint.set("nodes/node_a", start)
	$Joints.add_child(beginning_joint)
	
	for i in range(number_of_segments):
		segment = ROPE_SEGMENT.instance()
		joint = HingeJoint.new()
		joint.rotate_x(deg2rad(90.0))
		$Joints.add_child(joint)
		$Segments.add_child(segment)
		segment.global_translation = start_pos + i/number_of_segments * (end_pos - start_pos)
		
		prev_joint.set("nodes/node_b", segment.get_path())
		joint.set("nodes/node_a", segment.get_path())
		
		prev_joint = joint


	joint.set("nodes/node_b", end)
