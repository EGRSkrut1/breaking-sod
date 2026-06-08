extends Node2D

const GRID_SIZE = 16
const GRID_WIDTH = 25
const GRID_HEIGHT = 25
const BUILD_RANGE = 3

@onready var grid_manager = $GridManager
@onready var water_manager = $WaterManager
@onready var z_index_manager = $ZIndexManager
@onready var build_manager = $BuildManager
@onready var preview_manager = $PreviewManager
@onready var save_load_manager = $SaveLoadManager

var player_pos: Vector2i = Vector2i.ZERO
var player = null

func _ready():
	print("[Forest] Started")
	
	save_load_manager.set_crop_data_source("forest")
	save_load_manager.set_buildings_data_source("forest")
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	if player:
		update_player_pos()
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			camera.limit_left = -100000
			camera.limit_top = -100000
			camera.limit_right = 100000
			camera.limit_bottom = 100000
		
		player.z_index = 100
		
		if GameManager.player_position != Vector2.ZERO:
			player.global_position = GameManager.player_position
			print("[Forest] Player position loaded: ", GameManager.player_position)
	
	preview_manager.setup(self)
	save_load_manager.setup(self)
	
	water_manager.load_water_from_save()
	await save_load_manager.load_crops(grid_manager, Callable(self, "add_crop"))
	save_load_manager.load_buildings(Callable(self, "add_building"))
	
	players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		player.z_index = 100
	
	if z_index_manager and player:
		z_index_manager.setup(player)
		z_index_manager.refresh()
	
	var ui = get_node_or_null("UI")
	if ui:
		if ui.has_method("update_all"):
			ui.update_all()
		_reconnect_ui_signals(ui)
	
	print("[Forest] Ready")

func _reconnect_ui_signals(ui: CanvasLayer):
	var top_panel = ui.get_node_or_null("TopPanel")
	if top_panel:
		var calendar_button = top_panel.get_node_or_null("calendar")
		var suspicion_bar = top_panel.get_node_or_null("Suspicion")
		if calendar_button:
			if calendar_button.mouse_entered.is_connected(_on_calendar_hover):
				calendar_button.mouse_entered.disconnect(_on_calendar_hover)
			if calendar_button.mouse_exited.is_connected(_on_calendar_hover_end):
				calendar_button.mouse_exited.disconnect(_on_calendar_hover_end)
			calendar_button.mouse_entered.connect(_on_calendar_hover.bind(calendar_button, ui))
			calendar_button.mouse_exited.connect(_on_calendar_hover_end.bind(ui))
		if suspicion_bar:
			if suspicion_bar.mouse_entered.is_connected(_on_suspicion_hover):
				suspicion_bar.mouse_entered.disconnect(_on_suspicion_hover)
			if suspicion_bar.mouse_exited.is_connected(_on_suspicion_hover_end):
				suspicion_bar.mouse_exited.disconnect(_on_suspicion_hover_end)
			suspicion_bar.mouse_entered.connect(_on_suspicion_hover.bind(suspicion_bar, ui))
			suspicion_bar.mouse_exited.connect(_on_suspicion_hover_end.bind(ui))
	
	var states_panel = ui.get_node_or_null("StatesPanel")
	if states_panel:
		var energy_bar = states_panel.get_node_or_null("Energy")
		var sleep_bar = states_panel.get_node_or_null("Sleep")
		if energy_bar:
			if energy_bar.mouse_entered.is_connected(_on_energy_hover):
				energy_bar.mouse_entered.disconnect(_on_energy_hover)
			if energy_bar.mouse_exited.is_connected(_on_energy_hover_end):
				energy_bar.mouse_exited.disconnect(_on_energy_hover_end)
			energy_bar.mouse_entered.connect(_on_energy_hover.bind(energy_bar, ui))
			energy_bar.mouse_exited.connect(_on_energy_hover_end.bind(ui))
		if sleep_bar:
			if sleep_bar.mouse_entered.is_connected(_on_sleep_hover):
				sleep_bar.mouse_entered.disconnect(_on_sleep_hover)
			if sleep_bar.mouse_exited.is_connected(_on_sleep_hover_end):
				sleep_bar.mouse_exited.disconnect(_on_sleep_hover_end)
			sleep_bar.mouse_entered.connect(_on_sleep_hover.bind(sleep_bar, ui))
			sleep_bar.mouse_exited.connect(_on_sleep_hover_end.bind(ui))
	
	var water_bar = ui.get_node_or_null("WaterBar")
	if water_bar:
		var progress_bar = water_bar.get_node_or_null("ProgressBar")
		if progress_bar:
			if progress_bar.mouse_entered.is_connected(_on_water_hover):
				progress_bar.mouse_entered.disconnect(_on_water_hover)
			if progress_bar.mouse_exited.is_connected(_on_water_hover_end):
				progress_bar.mouse_exited.disconnect(_on_water_hover_end)
			progress_bar.mouse_entered.connect(_on_water_hover.bind(progress_bar, ui))
			progress_bar.mouse_exited.connect(_on_water_hover_end.bind(ui))

func _on_calendar_hover(button, ui: CanvasLayer):
	var message = "Day: " + str(GameManager.game_day) + "\n"
	message += "Time: " + str(GameManager.game_hours).pad_zeros(2) + ":" + str(GameManager.game_minutes).pad_zeros(2)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(message, button.global_position)

func _on_calendar_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_suspicion_hover(bar, ui: CanvasLayer):
	var text = "Suspicion: " + str(GameManager.suspicion) + "%"
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, bar.global_position)

func _on_suspicion_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_energy_hover(bar, ui: CanvasLayer):
	var text = "Energy: " + str(GameManager.energy) + "/" + str(GameManager.max_energy)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, bar.global_position)

func _on_energy_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_sleep_hover(bar, ui: CanvasLayer):
	var text = "Sleep: " + str(GameManager.sleep) + "/" + str(GameManager.max_sleep)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, bar.global_position)

func _on_sleep_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_water_hover(bar, ui: CanvasLayer):
	var current = water_manager.get_current_water() if water_manager else 0
	var max_water = water_manager.get_max_water() if water_manager else 0
	var text = "Water: " + str(current) + "/" + str(max_water)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, bar.global_position)

func _on_water_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _process(delta):
	queue_redraw()
	update_player_pos()
	if z_index_manager:
		z_index_manager.update_z_index()
	preview_manager.update_preview(
		build_manager.get_selected_item(),
		build_manager.is_watering_mode(),
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
	var ui = get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		var mouse_pos = get_global_mouse_position()
		ui.show_floating_text(text, color, mouse_pos)

func _draw():
	for x in range(0, GRID_WIDTH * GRID_SIZE, GRID_SIZE):
		draw_line(Vector2(x, 0), Vector2(x, GRID_HEIGHT * GRID_SIZE), Color(0.5, 0.5, 0.5, 0.5), 1)
	for y in range(0, GRID_HEIGHT * GRID_SIZE, GRID_SIZE):
		draw_line(Vector2(0, y), Vector2(GRID_WIDTH * GRID_SIZE, y), Color(0.5, 0.5, 0.5, 0.5), 1)

func _input(event):
	if event.is_action_pressed("watering"):
		print("[Forest] Watering mode toggled")
		build_manager.toggle_watering_mode()
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("cancel"):
		print("[Forest] ESC/Cancel pressed")
		handle_escape()
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("console"):
		print("[Forest] Console toggled")
		toggle_console()
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("interact"):
		print("[Forest] Interact pressed")
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
	
	if not build_manager.is_watering_mode() and build_manager.get_selected_item() == "":
		var crop = grid_manager.get_cell(grid_x, grid_y)
		if crop and crop.is_planted and crop.current_plant and crop.current_plant.is_ready_to_harvest():
			print("[Forest] Harvesting crop")
			crop.harvest()
			save_load_manager.save_all_crops(grid_manager)
			water_manager.save_water_state()
		return
	
	if build_manager.is_watering_mode():
		var crop = grid_manager.get_cell(grid_x, grid_y)
		if crop and crop.current_plant:
			if water_manager.use_water():
				print("[Forest] Watering plant")
				crop.water()
				save_load_manager.save_all_crops(grid_manager)
				water_manager.save_water_state()
			else:
				show_error_message("Not enough water", Color(1, 0.5, 0))
		return
	
	var selected_item = build_manager.get_selected_item()
	print("[Forest] Building item: ", selected_item)
	
	if selected_item == "crop":
		if grid_manager.is_cell_empty(grid_x, grid_y):
			if grid_manager.is_adjacent_to_crop(grid_x, grid_y):
				show_error_message("Cannot place adjacent to crop", Color(1, 1, 0))
				return
			if GameManager.use_inventory_item("crop"):
				print("[Forest] Placing crop")
				add_crop(grid_x, grid_y)
				save_load_manager.save_all_crops(grid_manager)
				water_manager.save_water_state()
				
				var ui = get_node_or_null("UI")
				if ui and ui.has_method("show_floating_text"):
					ui.show_floating_text("-1 crop", Color(1, 0.5, 0, 1), mouse_pos)
			else:
				show_error_message("No crop in inventory", Color(1, 0, 0))
		else:
			show_error_message("Cell not empty", Color(1, 0.5, 0))
	elif selected_item in ["well", "atm", "pc", "basement", "bed", "graver", "dryer", "wrapper", "laptop"]:
		if not grid_manager.is_cell_empty(grid_x, grid_y):
			show_error_message("Cell not empty", Color(1, 0.5, 0))
			return
		if selected_item == "atm":
			if grid_x < 2 or grid_x > GRID_WIDTH - 3 or grid_y < 2 or grid_y > GRID_HEIGHT - 3:
				show_error_message("ATM cannot be placed on edge", Color(1, 0, 0))
				return
		if GameManager.use_inventory_item(selected_item):
			print("[Forest] Placing building: ", selected_item)
			add_building(grid_x, grid_y, selected_item)
			save_load_manager.save_all_buildings()
			water_manager.save_water_state()
			
			var ui = get_node_or_null("UI")
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("-1 " + selected_item, Color(1, 0.5, 0, 1), mouse_pos)
		else:
			show_error_message("No " + selected_item + " in inventory", Color(1, 0, 0))
	elif selected_item in ["green", "purple", "white"]:
		var crop = grid_manager.get_cell(grid_x, grid_y)
		if not crop:
			show_error_message("No crop here", Color(1, 0.5, 0))
			return
		if crop.is_planted:
			show_error_message("Crop already planted", Color(1, 0.5, 0))
			return
		if selected_item == "green" and GameManager.has_seed("green"):
			print("[Forest] Planting green seed")
			crop.plant_seed("green")
			GameManager.use_seed("green")
			save_load_manager.save_all_crops(grid_manager)
			water_manager.save_water_state()
			
			var ui = get_node_or_null("UI")
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("-1 " + selected_item + " seed", Color(1, 0.5, 0, 1), mouse_pos)
		elif selected_item == "purple" and GameManager.unlocked_seeds.get("purple", false) and GameManager.has_seed("purple"):
			print("[Forest] Planting purple seed")
			crop.plant_seed("purple")
			GameManager.use_seed("purple")
			save_load_manager.save_all_crops(grid_manager)
			water_manager.save_water_state()
			
			var ui = get_node_or_null("UI")
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("-1 " + selected_item + " seed", Color(1, 0.5, 0, 1), mouse_pos)
		elif selected_item == "white" and GameManager.unlocked_seeds.get("white", false) and GameManager.has_seed("white"):
			print("[Forest] Planting white seed")
			crop.plant_seed("white")
			GameManager.use_seed("white")
			save_load_manager.save_all_crops(grid_manager)
			water_manager.save_water_state()
			
			var ui = get_node_or_null("UI")
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("-1 " + selected_item + " seed", Color(1, 0.5, 0, 1), mouse_pos)
		else:
			show_error_message("No seeds of this type", Color(1, 0, 0))

func handle_escape():
	var ui = get_node_or_null("UI")
	
	if build_manager.get_selected_item() != "":
		build_manager.clear_build_item()
		preview_manager.clear_preview()
		print("[Forest] Cleared build selection")
		return
	
	if build_manager.is_watering_mode():
		build_manager.clear_build_item()
		print("[Forest] Turned off watering mode")
		return
	
	var computer_ui = get_node_or_null("ComputerUI")
	var atm_ui = get_node_or_null("AtmUI")
	var customer_ui = get_node_or_null("CustomerUI")
	var map_choice_ui = get_node_or_null("MapChoiceUI")
	var console_ui = get_node_or_null("Console")
	
	if computer_ui and computer_ui.visible:
		computer_ui.visible = false
		print("[Forest] Closed ComputerUI")
		return
	if atm_ui and atm_ui.visible:
		atm_ui.visible = false
		print("[Forest] Closed AtmUI")
		return
	if customer_ui and customer_ui.visible:
		customer_ui.visible = false
		print("[Forest] Closed CustomerUI")
		return
	if map_choice_ui and map_choice_ui.visible:
		map_choice_ui.visible = false
		print("[Forest] Closed MapChoiceUI")
		return
	if console_ui and console_ui.visible:
		console_ui.visible = false
		print("[Forest] Closed Console")
		return
	
	if ui and ui.is_any_menu_open():
		ui.close_all_menus()
		print("[Forest] Closed UI menu")
		return
	
	if ui:
		var pause_menu = ui.get_node_or_null("pause_menu")
		if pause_menu:
			pause_menu.visible = !pause_menu.visible
			print("[Forest] Toggled pause menu")
		return

func toggle_console():
	var console = get_node_or_null("Console")
	if console:
		console.visible = !console.visible
		print("[Forest] Console visible: ", console.visible)

func add_crop(grid_x: int, grid_y: int):
	var path = "res://buildings/crop/crop.tscn"
	if not FileAccess.file_exists(path):
		print("[Forest] Crop scene not found")
		return
	var crop_scene = load(path)
	if not crop_scene:
		return
	var crop = crop_scene.instantiate()
	crop.position = Vector2(grid_x * GRID_SIZE + GRID_SIZE/2, grid_y * GRID_SIZE + GRID_SIZE/2)
	crop.set_cell_pos(Vector2(grid_x, grid_y))
	add_child(crop)
	grid_manager.add_crop(grid_x, grid_y, crop)
	move_child(crop, 0)
	print("[Forest] Crop added at ", grid_x, ",", grid_y)

func add_building(grid_x: int, grid_y: int, building_type: String):
	var path = "res://buildings/" + building_type + "/" + building_type + ".tscn"
	
	if building_type == "laptop":
		path = "res://buildings/pc/pc.tscn"
	if building_type == "pc":
		path = "res://buildings/pc/pc.tscn"
	
	if not FileAccess.file_exists(path):
		print("[Forest] Building file not found: ", path)
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
	print("[Forest] Building added: ", building_type, " at ", grid_x, ",", grid_y)

func set_selected_build_item(item: String):
	build_manager.select_build_item(item)

func refill_water():
	water_manager.refill_water()

func get_current_water() -> int:
	if water_manager:
		return water_manager.get_current_water()
	return 0

func get_max_water() -> int:
	if water_manager:
		return water_manager.get_max_water()
	return 0

func use_water() -> bool:
	if water_manager:
		return water_manager.use_water()
	return false

func save_all_crops():
	save_load_manager.save_all_crops(grid_manager)

func save_water_state():
	water_manager.save_water_state()

func get_crop_at_mouse() -> Node:
	var mouse_pos = get_global_mouse_position()
	var grid_x = floor(mouse_pos.x / GRID_SIZE)
	var grid_y = floor(mouse_pos.y / GRID_SIZE)
	if grid_x >= 0 and grid_x < GRID_WIDTH and grid_y >= 0 and grid_y < GRID_HEIGHT:
		return grid_manager.get_cell(grid_x, grid_y)
	return null
