extends Node

var astarGridSmall = AStarGrid2D.new() 
var astarGridMedium = AStarGrid2D.new() # for enemies twice the size of tiles

var tilemap: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilemap = get_tree().current_scene.get_node("Dungeon Map/BackgroundLayer")
	setupGridSmall()
	setupGridMedium()
	

func setupGridSmall() -> void:
	astarGridSmall.region = tilemap.get_used_rect()
	astarGridSmall.cell_size = tilemap.tile_set.tile_size
	
	astarGridSmall.jumping_enabled = false
	astarGridSmall.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astarGridSmall.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	
	astarGridSmall.update()
	
	for cell in tilemap.get_used_cells():
		var tileData = tilemap.get_cell_tile_data(cell)
		
		if tileData and tileData.get_custom_data("type") == "wall":
			astarGridSmall.set_point_solid(cell)
		



func setupGridMedium() -> void:
	astarGridMedium.region = tilemap.get_used_rect()
	astarGridMedium.cell_size = tilemap.tile_set.tile_size
	
	astarGridMedium.jumping_enabled = false
	astarGridMedium.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astarGridMedium.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	
	astarGridMedium.update()
	
	for cell in tilemap.get_used_cells():
		var tileData = tilemap.get_cell_tile_data(cell)
		
		if tileData and tileData.get_custom_data("type") == "wall":
			astarGridMedium.set_point_solid(cell)
		
			# add clearance around walls
			for x in range(-1, 2):
				for y in range(-1, 2):
					var extraWall = cell + Vector2i(x, y)
					if astarGridMedium.region.has_point(extraWall):
						astarGridMedium.set_point_solid(extraWall)


func calculatePath(startPosition: Vector2, targetPosition: Vector2, size: String) -> Array[Vector2i]:
	var startTile = tilemap.local_to_map(tilemap.to_local(startPosition))
	var targetTile = tilemap.local_to_map(tilemap.to_local(targetPosition))
	var grid: AStarGrid2D
	
	match size:
		"Small":
			grid = astarGridSmall
		"Medium":
			grid = astarGridMedium
	
	if grid.is_point_solid(targetTile):
		targetTile = findClosestWalkableTile(targetTile, size)
	
	if grid.is_point_solid(startTile):
		startTile = findClosestWalkableTile(startTile, size)
	
	return grid.get_id_path(startTile, targetTile)


func findClosestWalkableTile(tile: Vector2i, size: String) -> Vector2i:
	var closestTile = tile
	var closestDistance = 10000
	var grid: AStarGrid2D
	
	match size:
		"Small":
			grid = astarGridSmall
		"Medium":
			grid = astarGridMedium
	
	for x in range(-4, 5):
		for y in range(-4, 5):
			var cell = tile + Vector2i(x, y)
			
			if not grid.region.has_point(cell):
				continue
			
			if grid.is_point_solid(cell):
				continue
			
			var distance = tile.distance_to(cell)
			
			if distance < closestDistance:
				closestDistance = distance
				closestTile = cell
	return closestTile
