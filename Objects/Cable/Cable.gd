extends Spatial

const SEGMENT = preload("res://Objects/Cable/CableSegment.tscn")
var segments = []

export var seg_length = .25
export var width := .15
export var resolution := 8

export var stretch_start := .35
export var stretch_end := .38

var cable_force_points := 5

func _physics_process(delta):
	render()
	test_cable_stretch()

var player_a
var player_b
func set_players(a, b):
	player_a = a
	player_b = b

var highest_distance: float
var average_distance: float
func test_cable_stretch():
	if segments.empty():
		return
	var sum = 0.0
	var most = 0.0
	for i in range(len(segments)-1):
		var dist = segments[i].global_translation.distance_to(segments[i+1].global_translation)
		sum += dist
		if dist > most:
			most = dist
	highest_distance = most
	average_distance = sum / (len(segments)-1)
	if Game.ui != null:
		Game.ui.set_rope_length("average %.4f / highest %.4f" % [average_distance, highest_distance])
	var stretch_factor := clamp((average_distance - stretch_start) / (stretch_end  - stretch_start), 0.0, 1.0)
	
	# No low distance pushing
	var distance_between_players : float = segments[0].global_translation.distance_to(segments[-1].global_translation)
	stretch_factor *= smoothstep(3.0, 3.5, distance_between_players)
	var alert_factor = 1.5 if distance_between_players > 5.2 else 1.0
	
	var direction_for_a : Vector3 = segments[0].global_translation.direction_to(segments[1].global_translation)
	var direction_for_b : Vector3 = segments[-1].global_translation.direction_to(segments[-2].global_translation)
	for i in range(1, cable_force_points):
		direction_for_a += segments[0].global_translation.direction_to(segments[i+1].global_translation)
		direction_for_b += segments[-1].global_translation.direction_to(segments[-2-i].global_translation)
	player_a.cable_force = direction_for_a.normalized() * stretch_factor * alert_factor
	player_b.cable_force = direction_for_b.normalized() * stretch_factor * alert_factor
	#$ImmediateGeometry.material_override.set("shader_param/albedo", lerp(Color.white, Color.red, stretch_factor))
	

func create_cable(piece_a: Spatial, piece_b: Spatial):
	Game.cable = self
	$CableEndA.set_target(piece_a)
	$CableEndB.set_target(piece_b)
	var dist = piece_a.global_translation.distance_to(piece_b.global_translation)
	$CableEndA.look_at_from_position($CableEndA.global_translation, $CableEndB.global_translation, Vector3.UP)
	var cable_rotation = $CableEndA.global_rotation
	var estimated_segments = int(dist / seg_length)
	add_segment($CableEndA, cable_rotation)
	for i in range(estimated_segments-1):
		if segments[i].global_translation.distance_to($CableEndB.global_translation) < seg_length:
			pass#break
		add_segment(segments[i], cable_rotation)
	var old_pos = $CableEndB.global_translation
	$CableEndB.global_translation = segments[-1].get_node("C/J").global_translation
	segments[-1].get_node("C/J").set("nodes/node_a", segments[-1].get_path())
	segments[-1].get_node("C/J").set("nodes/node_b", $CableEndB.get_path())
	
	segments.insert(0, $CableEndA)
	segments.append($CableEndB)

func add_segment(parent_segment, target_rotation):
	var joint : PinJoint = parent_segment.get_node("C/J")
	var new_segment = SEGMENT.instance()
	add_child(new_segment)
	new_segment.set_length(seg_length)
	new_segment.global_translation = joint.global_translation
	new_segment.global_rotation = target_rotation
	joint.set("nodes/node_a", parent_segment.get_path())
	joint.set("nodes/node_b", new_segment.get_path())
	segments.append(new_segment)

func get_directed_circle_points(origin: Vector3, direction: Vector3, res: int, wid: float) -> Array:
	direction = direction.normalized()
	if direction.length() == 0.0:
		direction = Vector3.UP
	var start_point := Vector3.UP.cross(direction).cross(direction).normalized()
	var circle_points := []
	for i in range(res):
		circle_points.append(origin + wid * start_point.rotated(direction, 2.0*PI*float(i)/res))
	return circle_points

func render():
	if not segments.empty():
		var segment_points := []
		for s in segments: segment_points.append(s.global_translation)
		var segment_count := len(segments)
		var segment_verts := []
		
		for i in range(segment_count - 1):
			var a : Vector3 = segment_points[i]
			var b : Vector3 = segment_points[i+1]
			if a == b:
				return
			segment_verts.append(get_directed_circle_points(a, b-a, resolution, width))
			if i == segment_count - 2: # for the last segment
				segment_verts.append(get_directed_circle_points(b, b-a, resolution, width))
		
		$ImmediateGeometry.clear()
		$ImmediateGeometry.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		for i in range(segment_count - 1):
			var verts_a : Array = segment_verts[i]
			var verts_b : Array = segment_verts[i+1]
			for j in range(resolution):
				var left := j
				var right := (j + 1) % resolution
				
				$ImmediateGeometry.set_uv(Vector2(float(i)/(segment_count-1), 0))
				$ImmediateGeometry.add_vertex(verts_a[left])
				$ImmediateGeometry.set_uv(Vector2(float(i+1)/(segment_count-1), 0))
				$ImmediateGeometry.add_vertex(verts_b[left])
				$ImmediateGeometry.set_uv(Vector2(float(i)/(segment_count-1), 1))
				$ImmediateGeometry.add_vertex(verts_a[right])
				
				$ImmediateGeometry.set_uv(Vector2(float(i+1)/(segment_count-1), 0))
				$ImmediateGeometry.add_vertex(verts_b[left])
				$ImmediateGeometry.set_uv(Vector2(float(i+1)/(segment_count-1), 1))
				$ImmediateGeometry.add_vertex(verts_b[right])
				$ImmediateGeometry.set_uv(Vector2(float(i)/(segment_count-1), 1))
				$ImmediateGeometry.add_vertex(verts_a[right])

		$ImmediateGeometry.end()
