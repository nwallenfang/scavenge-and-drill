extends Node2D

const TILE_SIZE = Vector2(64, 64)

func map_start() -> void:
	# @todo Things you want to happen when the map starts.
	pass

func map_stop() -> void:
	# @todo Things you want to happen when the map stops.
	pass

func get_map_rect() -> Rect2:
	var rect: Rect2
	for child in get_children():
		if child is TileMap:
			if rect == null:
				rect = child.get_used_rect()
			else:
				rect = rect.merge(child.get_used_rect())
	return Rect2(rect.position * TILE_SIZE, rect.size * TILE_SIZE)
	
