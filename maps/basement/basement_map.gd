extends Node2D

const GRID_SIZE = 16
const GRID_WIDTH = 25
const GRID_HEIGHT = 25
const BUILD_RANGE = 3

var grid: Array = []
var player = null
var player_pos: Vector2i = Vector2i.ZERO

@onready var grid_manager = $GridManager
@onready var build_manager = $BuildManager
@onready var preview_manager = $PreviewManager
@onready var water_manager = $WaterManager
@onready var z_index_manager = $ZIndexManager
@onready var save_load_manager = $SaveLoadManager

func _ready():
	print("[BasementMap] Started")
	
	save_load_manager.set_crop_data_source("basement")
	save_load_manager.set_buildings_data_source("basement")
	
	for x in range(GRID_WIDTH):
		grid.append([])
		for y in range(GRID_HEIGHT):
			grid[x].append(null)
	
	await get_tree().process_frame
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("[BasementMap] Player found: ", player.name)
	
	if player:
		var ladder_x = GRID_WIDTH / 2
		var ladder_y = GRID_HEIGHT - 1
		var spawn_x = ladder_x * GRID_SIZE + GRID_SIZE/2
		var spawn_y = ladder_y * GRID_SIZE + GRID_SIZE/2
		
		if GameManager.basement_player_position != Vector2.ZERO:
			player.global_position = GameManager.basement_player_position
			print("[BasementMap] Player position loaded from basement save: ", GameManager.basement_player_position)
		else:
			player.global_position = Vector2(spawn_x, spawn_y)
			print("[BasementMap] Player spawned on ladder")
		
		player.z_index = 100
		
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			camera.limit_left = -100000
			camera.limit_top = -100000
			camera.limit_right = 100000
			camera.limit_bottom = 100000
	
	if build_manager:
		build_manager.reset()
	
	if preview_manager:
		preview_manager.setup(self)
	
	if save_load_manager:
		save_load_manager.setup(self)
		water_manager.load_water_from_save()
		await save_load_manager.load_crops(grid_manager, Callable(self, "add_crop"))
		save_load_manager.load_buildings(Callable(self, "add_building"))
	
	if z_index_manager and player:
		z_index_manager.setup(player)
	
	load_dirt_state()
	place_ladder()
	
	var ui = get_node_or_null("/root/Forest/UI")
	if ui and ui.has_method("update_all"):
		ui.update_all()
	
	print("[BasementMap] Ready")

func _process(delta):
	update_player_pos()
	if z_index_manager:
		z_index_manager.update_z_index()
	if preview_manager:
		preview_manager.update_preview(
			build_manager.get_selected_item() if build_manager else "",
			build_manager.is_watering_mode() if build_manager else false,
			floor(get_global_mouse_position().x / GRID_SIZE),
			floor(get_global_mouse_position().y / GRID_SIZE),
			is_in_range(floor(get_global_mouse_position().x / GRID_SIZE), floor(get_global_mouse_position().y / GRID_SIZE))
		)

func update_player_pos():
	if player:
		player.z_index = 100
		player_pos = Vector2i(
			floor(player.global_position.x / GRID_SIZE),
			floor(player.global_position.y / GRID_SIZE)
		)

func is_in_range(grid_x: int, grid_y: int) -> bool:
	if not player:
		return true
	return abs(grid_x - player_pos.x) <= BUILD_RANGE and abs(grid_y - player_pos.y) <= BUILD_RANGE

func show_error_message(text: String, color: Color):
	var ui = get_node_or_null("/root/Forest/UI")
	if not ui:
		var forest = get_tree().root.get_node_or_null("Forest")
		if forest:
			ui = forest.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		var mouse_pos = get_global_mouse_position()
		ui.show_floating_text(text, color, mouse_pos)

func load_dirt_state():
	var saved = GameManager.get_basement_dirt_data()
	if saved == null or saved.is_empty():
		print("[BasementMap] No saved dirt, generating new")
		generate_dirt()
	else:
		print("[BasementMap] Restoring saved dirt")
		restore_dirt(saved)

func generate_dirt():
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var ladder_x = GRID_WIDTH / 2
			var ladder_y = GRID_HEIGHT - 1
			var should_skip = false
			
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					if x == ladder_x + dx and y == ladder_y + dy:
						should_skip = true
						break
				if should_skip:
					break
			
			if should_skip:
				continue
			
			if y < GRID_HEIGHT - 3:
				add_dirt(x, y)
	save_dirt_state()

func save_dirt_state():
	var dirt_data = {}
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var dirt = grid[x][y]
			if dirt:
				dirt_data[str(x) + "," + str(y)] = {
					"type": dirt.type,
					"hp": dirt.hp
				}
	GameManager.save_basement_dirt_data(dirt_data)
	print("[BasementMap] Dirt state saved")

func restore_dirt(saved: Dictionary):
	for key in saved:
		var coords = key.split(",")
		if coords.size() == 2:
			var x = int(coords[0])
			var y = int(coords[1])
			var dirt_info = saved[key]
			add_dirt(x, y, dirt_info["type"], dirt_info["hp"])

func add_dirt(grid_x: int, grid_y: int, dirt_type: String = "", dirt_hp: int = 0):
	var path = "res://entity/dirt/dirt.tscn"
	if not FileAccess.file_exists(path):
		print("[BasementMap] dirt.tscn not found")
		return
	
	var dirt_scene = load(path)
	if not dirt_scene:
		return
	
	var dirt = dirt_scene.instantiate()
	dirt.position = Vector2(grid_x * GRID_SIZE + GRID_SIZE/2, grid_y * GRID_SIZE + GRID_SIZE/2)
	dirt.set_cell_pos(Vector2(grid_x, grid_y))
	
	if dirt_type != "":
		dirt.set_type(dirt_type)
		dirt.hp = dirt_hp
	else:
		var rng = randi() % 10
		if rng < 2:
			dirt.set_type("stone")
		else:
			dirt.set_type("dirt")
	
	add_child(dirt)
	grid[grid_x][grid_y] = dirt

func place_ladder():
	var path = "res://maps/transition function/ladder/ladder.tscn"
	if not FileAccess.file_exists(path):
		print("[BasementMap] ladder.tscn not found")
		return
	
	var ladder_scene = load(path)
	if not ladder_scene:
		return
	
	var ladder = ladder_scene.instantiate()
	var ladder_x = (GRID_WIDTH / 2) * GRID_SIZE + GRID_SIZE/2
	var ladder_y = (GRID_HEIGHT - 1) * GRID_SIZE + GRID_SIZE/2
	ladder.position = Vector2(ladder_x, ladder_y)
	ladder.set_cell_pos(Vector2(GRID_WIDTH / 2, GRID_HEIGHT - 1))
	add_child(ladder)
	print("[BasementMap] Ladder placed")

func remove_dirt(grid_x: int, grid_y: int):
	var dirt = grid[grid_x][grid_y]
	if dirt:
		dirt.queue_free()
		grid[grid_x][grid_y] = null
		save_dirt_state()
		print("[BasementMap] Dirt removed at ", grid_x, ",", grid_y)

func _draw():
	for x in range(0, GRID_WIDTH * GRID_SIZE, GRID_SIZE):
		draw_line(Vector2(x, 0), Vector2(x, GRID_HEIGHT * GRID_SIZE), Color(0.5, 0.5, 0.5, 0.5), 1)
	for y in range(0, GRID_HEIGHT * GRID_SIZE, GRID_SIZE):
		draw_line(Vector2(0, y), Vector2(GRID_WIDTH * GRID_SIZE, y), Color(0.5, 0.5, 0.5, 0.5), 1)

func _input(event):
	if event.is_action_pressed("watering"):
		if build_manager:
			build_manager.toggle_watering_mode()
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("cancel"):
		handle_escape()
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("interact"):
		if player and player.has_method("interact"):
			player.interact()
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_left_click(event)
		return

func handle_left_click(event):
	var mouse_pos = get_global_mouse_position()
	var grid_x = floor(mouse_pos.x / GRID_SIZE)
	var grid_y = floor(mouse_pos.y / GRID_SIZE)
	
	if grid_x < 0 or grid_x >= GRID_WIDTH or grid_y < 0 or grid_y >= GRID_HEIGHT:
		return
	
	if not is_in_range(grid_x, grid_y):
		show_error_message("Cannot build here", Color(1, 0, 0))
		return
	
	if not build_manager:
		return
	
	if not build_manager.is_watering_mode() and build_manager.get_selected_item() == "":
		var dirt = get_dirt_at(grid_x, grid_y)
		if dirt and dirt.has_method("mine"):
			var dist = player.global_position.distance_to(dirt.global_position)
			if dist < 100:
				print("[BasementMap] Mining dirt")
				dirt.mine()
		else:
			var crop = grid_manager.get_cell(grid_x, grid_y) if grid_manager else null
			if crop and crop.is_planted and crop.current_plant and crop.current_plant.is_ready_to_harvest():
				print("[BasementMap] Harvesting crop")
				crop.harvest()
				if save_load_manager:
					save_load_manager.save_all_crops(grid_manager)
		return
	
	if build_manager.is_watering_mode():
		var crop = grid_manager.get_cell(grid_x, grid_y) if grid_manager else null
		if crop and crop.current_plant:
			if water_manager and water_manager.use_water():
				print("[BasementMap] Watering plant")
				crop.water()
				if save_load_manager:
					save_load_manager.save_all_crops(grid_manager)
					water_manager.save_water_state()
			else:
				show_error_message("Not enough water", Color(1, 0.5, 0))
		else:
			show_error_message("No plant to water", Color(1, 0.5, 0))
		return
	
	var selected_item = build_manager.get_selected_item()
	print("[BasementMap] Building item: ", selected_item)
	
	if selected_item == "crop":
		if is_cell_empty(grid_x, grid_y):
			if GameManager.use_inventory_item("crop"):
				print("[BasementMap] Placing crop")
				add_crop(grid_x, grid_y)
				if save_load_manager:
					save_load_manager.save_all_crops(grid_manager)
					water_manager.save_water_state()
				var ui = get_node_or_null("/root/Forest/UI")
				if ui and ui.has_method("show_floating_text"):
					ui.show_floating_text("-1 crop", Color(1, 0.5, 0, 1), mouse_pos)
			else:
				show_error_message("No crop in inventory", Color(1, 0, 0))
		else:
			show_error_message("Cell not empty", Color(1, 0.5, 0))
	elif selected_item in ["well", "atm", "pc", "basement", "bed", "graver", "dryer", "wrapper", "laptop"]:
		if is_cell_empty(grid_x, grid_y):
			if selected_item == "atm":
				if grid_x < 2 or grid_x > GRID_WIDTH - 3 or grid_y < 2 or grid_y > GRID_HEIGHT - 3:
					show_error_message("ATM cannot be placed on edge", Color(1, 0, 0))
					return
			if GameManager.use_inventory_item(selected_item):
				print("[BasementMap] Placing building: ", selected_item)
				add_building(grid_x, grid_y, selected_item)
				if save_load_manager:
					save_load_manager.save_all_buildings()
					water_manager.save_water_state()
				var ui = get_node_or_null("/root/Forest/UI")
				if ui and ui.has_method("show_floating_text"):
					ui.show_floating_text("-1 " + selected_item, Color(1, 0.5, 0, 1), mouse_pos)
			else:
				show_error_message("No " + selected_item + " in inventory", Color(1, 0, 0))
		else:
			show_error_message("Cell not empty", Color(1, 0.5, 0))
	elif selected_item in ["green", "purple", "white"]:
		var crop = grid_manager.get_cell(grid_x, grid_y) if grid_manager else null
		if not crop:
			show_error_message("No crop here", Color(1, 0.5, 0))
			return
		if crop.is_planted:
			show_error_message("Crop already planted", Color(1, 0.5, 0))
			return
		if selected_item == "green" and GameManager.has_seed("green"):
			print("[BasementMap] Planting green seed")
			crop.plant_seed("green")
			GameManager.use_seed("green")
			if save_load_manager:
				save_load_manager.save_all_crops(grid_manager)
				water_manager.save_water_state()
			var ui = get_node_or_null("/root/Forest/UI")
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("-1 " + selected_item + " seed", Color(1, 0.5, 0, 1), mouse_pos)
		elif selected_item == "purple" and GameManager.unlocked_seeds.get("purple", false) and GameManager.has_seed("purple"):
			print("[BasementMap] Planting purple seed")
			crop.plant_seed("purple")
			GameManager.use_seed("purple")
			if save_load_manager:
				save_load_manager.save_all_crops(grid_manager)
				water_manager.save_water_state()
			var ui = get_node_or_null("/root/Forest/UI")
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("-1 " + selected_item + " seed", Color(1, 0.5, 0, 1), mouse_pos)
		elif selected_item == "white" and GameManager.unlocked_seeds.get("white", false) and GameManager.has_seed("white"):
			print("[BasementMap] Planting white seed")
			crop.plant_seed("white")
			GameManager.use_seed("white")
			if save_load_manager:
				save_load_manager.save_all_crops(grid_manager)
				water_manager.save_water_state()
			var ui = get_node_or_null("/root/Forest/UI")
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("-1 " + selected_item + " seed", Color(1, 0.5, 0, 1), mouse_pos)
		else:
			show_error_message("No seeds of this type", Color(1, 0, 0))

func get_dirt_at(grid_x: int, grid_y: int):
	if grid_x >= 0 and grid_x < GRID_WIDTH and grid_y >= 0 and grid_y < GRID_HEIGHT:
		return grid[grid_x][grid_y]
	return null

func is_cell_empty(grid_x: int, grid_y: int) -> bool:
	var crop = grid_manager.get_cell(grid_x, grid_y) if grid_manager else null
	var dirt = get_dirt_at(grid_x, grid_y)
	return crop == null and dirt == null

func add_crop(grid_x: int, grid_y: int):
	var path = "res://buildings/crop/crop.tscn"
	if not FileAccess.file_exists(path):
		print("[BasementMap] Crop scene not found")
		return
	var crop_scene = load(path)
	if not crop_scene:
		return
	var crop = crop_scene.instantiate()
	crop.position = Vector2(grid_x * GRID_SIZE + GRID_SIZE/2, grid_y * GRID_SIZE + GRID_SIZE/2)
	crop.set_cell_pos(Vector2(grid_x, grid_y))
	add_child(crop)
	if grid_manager and grid_manager.has_method("add_crop"):
		grid_manager.add_crop(grid_x, grid_y, crop)
	print("[BasementMap] Crop added at ", grid_x, ",", grid_y)

func add_building(grid_x: int, grid_y: int, building_type: String):
	var path = "res://buildings/" + building_type + "/" + building_type + ".tscn"
	
	if building_type == "laptop":
		path = "res://buildings/pc/pc.tscn"
	if building_type == "pc":
		path = "res://buildings/pc/pc.tscn"
	
	if not FileAccess.file_exists(path):
		print("[BasementMap] Building file not found: ", path)
		return
	var building_scene = load(path)
	if not building_scene:
		return
	var building = building_scene.instantiate()
	building.position = Vector2(grid_x * GRID_SIZE + GRID_SIZE/2, grid_y * GRID_SIZE + GRID_SIZE/2)
	if building.has_method("set_cell_pos"):
		building.set_cell_pos(Vector2(grid_x, grid_y))
	add_child(building)
	building.add_to_group("buildings")
	print("[BasementMap] Building added: ", building_type, " at ", grid_x, ",", grid_y)

func handle_escape():
	if build_manager and build_manager.get_selected_item() != "":
		build_manager.clear_build_item()
		if preview_manager:
			preview_manager.clear_preview()
		print("[BasementMap] Cleared build selection")
		return
	
	if build_manager and build_manager.is_watering_mode():
		build_manager.clear_build_item()
		print("[BasementMap] Turned off watering mode")
		return
	
	var ui = get_node_or_null("/root/Forest/UI")
	if ui and ui.is_any_menu_open():
		ui.close_all_menus()
		print("[BasementMap] Closed UI menu")
		return
	
	if ui:
		var pause_menu = ui.get_node_or_null("pause_menu")
		if pause_menu:
			pause_menu.visible = !pause_menu.visible
			print("[BasementMap] Toggled pause menu")
		return

func return_to_main():
	print("[BasementMap] Returning to main")
	
	if player:
		GameManager.basement_player_position = player.global_position
		print("[BasementMap] Basement player position saved: ", GameManager.basement_player_position)
	
	if save_load_manager:
		save_load_manager.save_all_crops(grid_manager)
		save_load_manager.save_all_buildings()
		water_manager.save_water_state()
	
	save_dirt_state()
	
	var main_scene = load("res://maps/forest/forest.tscn").instantiate()
	
	get_tree().root.add_child(main_scene)
	get_tree().current_scene = main_scene
	
	GameManager.last_map = "res://maps/forest/forest.tscn"
	
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.z_index = 100
		var basements = main_scene.get_tree().get_nodes_in_group("basements")
		for basement in basements:
			if basement.has_method("get_cell_pos"):
				var basement_pos = basement.get_cell_pos()
				player_node.global_position = Vector2(basement_pos.x * GRID_SIZE + GRID_SIZE/2, basement_pos.y * GRID_SIZE + GRID_SIZE/2)
				print("[BasementMap] Player set to basement position: ", basement_pos)
				break
	
	queue_free()

func set_selected_build_item(item: String):
	if build_manager:
		build_manager.select_build_item(item)

func save_all_crops():
	if save_load_manager:
		save_load_manager.save_all_crops(grid_manager)

func save_water_state():
	if water_manager:
		water_manager.save_water_state()
