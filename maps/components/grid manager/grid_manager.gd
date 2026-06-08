extends Node
class_name GridManager

signal crop_added(crop, x, y)
signal crop_removed(x, y)

const GRID_SIZE = 16
const GRID_WIDTH = 25
const GRID_HEIGHT = 25

var grid: Array = []

# Initializes empty grid
func _ready():
	for x in range(GRID_WIDTH):
		grid.append([])
		for y in range(GRID_HEIGHT):
			grid[x].append(null)

# Returns crop at grid position
func get_cell(x: int, y: int):
	if x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT:
		return grid[x][y]
	return null

# Sets crop at grid position
func set_cell(x: int, y: int, value):
	if x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT:
		grid[x][y] = value
		return true
	return false

# Checks if grid cell is empty
func is_cell_empty(x: int, y: int) -> bool:
	return get_cell(x, y) == null

# Adds crop to grid
func add_crop(x: int, y: int, crop_node):
	if is_cell_empty(x, y):
		set_cell(x, y, crop_node)
		crop_added.emit(crop_node, x, y)
		return true
	return false

# Removes crop from grid
func remove_crop(x: int, y: int):
	var crop = get_cell(x, y)
	if crop:
		set_cell(x, y, null)
		crop_removed.emit(x, y)
		return crop
	return null

# Returns all crops in grid
func get_all_crops() -> Array:
	var crops = []
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			if grid[x][y]:
				crops.append({"crop": grid[x][y], "x": x, "y": y})
	return crops

# Checks if position is adjacent to any crop
func is_adjacent_to_crop(x: int, y: int) -> bool:
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var check_x = x + dx
			var check_y = y + dy
			if check_x >= 0 and check_x < GRID_WIDTH and check_y >= 0 and check_y < GRID_HEIGHT:
				if grid[check_x][check_y] != null:
					return true
	return false

# Returns grid dimensions
func get_grid_size() -> Vector2:
	return Vector2(GRID_WIDTH, GRID_HEIGHT)

# Returns world position of grid cell
func get_cell_world_position(x: int, y: int) -> Vector2:
	return Vector2(x * GRID_SIZE + GRID_SIZE/2, y * GRID_SIZE + GRID_SIZE/2)
