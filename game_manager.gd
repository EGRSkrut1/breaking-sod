extends Node

signal money_changed
signal seeds_changed
signal inventory_changed
signal card_money_changed
signal energy_changed
signal sleep_changed
signal time_changed
signal green_sold_changed
signal purple_sold_changed
signal white_sold_changed
signal suspicion_changed

var money: int = 100
var card_money: int = 0
var suspicion: int = 0
var max_suspicion: int = 100

var seeds: Dictionary = {
	"green": 3,
	"purple": 0,
	"white": 0
}

var inventory: Array = []

var unlocked_seeds: Dictionary = {
	"green": true,
	"purple": false,
	"white": false
}

var unlocked_equipment: Dictionary = {
	"graver": false,
	"dryer": false,
	"wrapper": false,
	"laptop": false,
	"bed": false
}

# Forest saves
var forest_crop_data: Dictionary = {}
var forest_buildings_data: Dictionary = {}

# Basement saves
var basement_crop_data: Dictionary = {}
var basement_buildings_data: Dictionary = {}
var basement_dirt_data: Dictionary = {}

# Shared water data
var water_data: Dictionary = {}

var last_map: String = "res://maps/forest/forest.tscn"
var player_position: Vector2 = Vector2.ZERO
var basement_player_position: Vector2 = Vector2.ZERO

var energy: int = 100
var max_energy: int = 100

var sleep: int = 48
var max_sleep: int = 48

var game_hours: int = 8
var game_minutes: int = 0
var game_day: int = 1

var game_time_timer: float = 0.0
var time_scale: float = 60.0

var green_sold: int = 0
var purple_sold: int = 0
var white_sold: int = 0

func _ready():
	print("[GameManager] Started")
	money_changed.connect(_on_money_changed)
	seeds_changed.connect(_on_seeds_changed)
	card_money_changed.connect(_on_card_money_changed)
	load_game()
	
	if inventory.is_empty():
		add_inventory_item({"type": "laptop", "name": "Laptop", "price": 500})
		add_inventory_item({"type": "bed", "name": "Bed", "price": 50})
		add_inventory_item({"type": "crop", "name": "Crop", "price": 10})
		add_inventory_item({"type": "basement", "name": "Basement", "price": 100})
	print("[GameManager] Ready")

func _process(delta):
	game_time_timer += delta * time_scale
	while game_time_timer >= 60.0:
		game_time_timer -= 60.0
		game_minutes += 1
		if game_minutes >= 60:
			game_minutes = 0
			game_hours += 1
			if game_hours >= 24:
				game_hours = 0
				game_day += 1
		time_changed.emit()

func _on_money_changed():
	print("[GameManager] Money changed: ", money)

func _on_seeds_changed():
	print("[GameManager] Seeds changed: ", seeds)

func _on_card_money_changed():
	print("[GameManager] Card money changed: ", card_money)

func add_money(amount: int):
	money += amount
	money_changed.emit()
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			ui.show_floating_text("+$" + str(amount), Color(0, 1, 0, 1), player.global_position + Vector2(0, -40))

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit()
		
		var ui = get_tree().current_scene.get_node_or_null("UI")
		if ui and ui.has_method("show_floating_text"):
			var player = get_tree().get_first_node_in_group("player")
			if player:
				ui.show_floating_text("-$" + str(amount), Color(1, 0, 0, 1), player.global_position + Vector2(0, -40))
		return true
	print("[GameManager] Not enough money")
	return false

func add_card_money(amount: int):
	card_money += amount
	card_money_changed.emit()
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			ui.show_floating_text("+$" + str(amount) + " card", Color(0, 1, 0, 1), player.global_position + Vector2(0, -40))

func spend_card_money(amount: int) -> bool:
	if card_money >= amount:
		card_money -= amount
		card_money_changed.emit()
		
		var ui = get_tree().current_scene.get_node_or_null("UI")
		if ui and ui.has_method("show_floating_text"):
			var player = get_tree().get_first_node_in_group("player")
			if player:
				ui.show_floating_text("-$" + str(amount) + " card", Color(1, 0, 0, 1), player.global_position + Vector2(0, -40))
		return true
	print("[GameManager] Not enough card money")
	return false

func add_suspicion(amount: int):
	suspicion = min(suspicion + amount, max_suspicion)
	suspicion_changed.emit()

func reset_suspicion():
	suspicion = 0
	suspicion_changed.emit()

func has_seed(seed_type: String) -> bool:
	if not unlocked_seeds.get(seed_type, false):
		return false
	return seeds.get(seed_type, 0) > 0

func use_seed(seed_type: String):
	if seeds.has(seed_type) and seeds[seed_type] > 0:
		seeds[seed_type] = int(seeds[seed_type]) - 1
		seeds_changed.emit()

func add_seeds(seed_type: String, amount: int):
	if seeds.has(seed_type):
		seeds[seed_type] = int(seeds[seed_type]) + amount
	else:
		seeds[seed_type] = amount
		seeds_changed.emit()

func unlock_seed(seed_type: String):
	unlocked_seeds[seed_type] = true

func unlock_equipment(equipment_type: String):
	unlocked_equipment[equipment_type] = true

func get_seed_count(seed_type: String) -> int:
	if not unlocked_seeds.get(seed_type, false):
		return 0
	return int(seeds.get(seed_type, 0))

func add_inventory_item(item: Dictionary):
	inventory.append(item)
	inventory_changed.emit()
	print("[GameManager] Added inventory item: ", item["name"])

func has_inventory_item(item_type: String) -> bool:
	for item in inventory:
		if item["type"] == item_type:
			return true
	return false

func remove_inventory_item(item_type: String):
	for i in range(inventory.size()):
		if inventory[i]["type"] == item_type:
			inventory.remove_at(i)
			inventory_changed.emit()
			print("[GameManager] Removed inventory item: ", item_type)
			return true
	return false

func use_inventory_item(item_type: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i]["type"] == item_type:
			inventory.remove_at(i)
			inventory_changed.emit()
			print("[GameManager] Used inventory item: ", item_type)
			return true
	return false

func sell_inventory_item(index: int):
	if index < inventory.size():
		money += inventory[index]["price"]
		inventory.remove_at(index)
		money_changed.emit()
		inventory_changed.emit()
		print("[GameManager] Sold inventory item at index: ", index)

# Forest save/load
func save_forest_crop_data(crop_dictionary: Dictionary):
	forest_crop_data = crop_dictionary

func get_forest_crop_data() -> Dictionary:
	print("[GameManager] Returning forest crop data, size: ", forest_crop_data.size())
	return forest_crop_data

func save_forest_buildings_data(buildings_dictionary: Dictionary):
	forest_buildings_data = buildings_dictionary

func get_forest_buildings_data() -> Dictionary:
	print("[GameManager] Returning forest buildings data, size: ", forest_buildings_data.size())
	return forest_buildings_data

# Basement save/load
func save_basement_crop_data(crop_dictionary: Dictionary):
	basement_crop_data = crop_dictionary

func get_basement_crop_data() -> Dictionary:
	print("[GameManager] Returning basement crop data, size: ", basement_crop_data.size())
	return basement_crop_data

func save_basement_buildings_data(buildings_dictionary: Dictionary):
	basement_buildings_data = buildings_dictionary

func get_basement_buildings_data() -> Dictionary:
	print("[GameManager] Returning basement buildings data, size: ", basement_buildings_data.size())
	return basement_buildings_data

func save_basement_dirt_data(data: Dictionary):
	basement_dirt_data = data

func get_basement_dirt_data() -> Dictionary:
	if basement_dirt_data == null:
		return {}
	print("[GameManager] Returning basement dirt data, size: ", basement_dirt_data.size())
	return basement_dirt_data

# Shared water data
func save_water_data(water_dictionary: Dictionary):
	water_data = water_dictionary
	print("[GameManager] Water data saved")

func get_water_data() -> Dictionary:
	print("[GameManager] Returning water data")
	return water_data

func use_energy(amount: int) -> bool:
	if energy >= amount:
		energy -= amount
		energy_changed.emit()
		return true
	print("[GameManager] Not enough energy")
	return false

func restore_energy(amount: int):
	var old_energy = energy
	energy = min(energy + amount, max_energy)
	energy_changed.emit()
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var gained = energy - old_energy
			if gained > 0:
				ui.show_floating_text("+ " + str(gained) + " energy", Color(1, 1, 0, 1), player.global_position + Vector2(0, -40))

func use_sleep(amount: int):
	sleep = max(sleep - amount, 0)
	sleep_changed.emit()
	
	if sleep <= 0:
		handle_sleep_pass_out()

func restore_sleep(amount: int):
	var old_sleep = sleep
	sleep = min(sleep + amount, max_sleep)
	sleep_changed.emit()
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var gained = sleep - old_sleep
			if gained > 0:
				ui.show_floating_text("+ " + str(gained) + " sleep", Color(0.8, 0.2, 0.8, 1), player.global_position + Vector2(0, -40))

func handle_sleep_pass_out():
	print("[GameManager] Player passed out from exhaustion!")
	
	var hours_awake = 48.0 - float(sleep)
	var sleep_hours = clamp(hours_awake * 0.33, 4.0, 16.0)
	var sleep_minutes = int(sleep_hours * 60.0)
	
	sleep = max_sleep
	sleep_changed.emit()
	
	game_minutes += sleep_minutes
	while game_minutes >= 60:
		game_minutes -= 60
		game_hours += 1
		if game_hours >= 24:
			game_hours = 0
			game_day += 1
	time_changed.emit()
	
	var hospital_bill = 500
	if money >= hospital_bill:
		money -= hospital_bill
	else:
		money = 0
	money_changed.emit()
	
	print("[GameManager] Passed out! Lost $", hospital_bill, " and slept for ", sleep_hours, " hours")

func add_sold_plant(plant_type: String):
	match plant_type:
		"green":
			green_sold += 1
			green_sold_changed.emit()
		"purple":
			purple_sold += 1
			purple_sold_changed.emit()
		"white":
			white_sold += 1
			white_sold_changed.emit()
	print("[GameManager] Sold plant: ", plant_type)

func new_game():
	print("[GameManager] Starting new game")
	money = 100
	card_money = 0
	suspicion = 0
	seeds = {
		"green": 3,
		"purple": 0,
		"white": 0
	}
	inventory = [
		{"type": "laptop", "name": "Laptop", "price": 500},
		{"type": "bed", "name": "Bed", "price": 50},
		{"type": "crop", "name": "Crop", "price": 10},
		{"type": "basement", "name": "Basement", "price": 100}
	]
	unlocked_seeds = {
		"green": true,
		"purple": false,
		"white": false
	}
	unlocked_equipment = {
		"graver": false,
		"dryer": false,
		"wrapper": false,
		"laptop": false,
		"bed": false
	}
	forest_crop_data = {}
	forest_buildings_data = {}
	basement_crop_data = {}
	basement_buildings_data = {}
	basement_dirt_data = {}
	water_data = {}
	last_map = "res://maps/forest/forest.tscn"
	player_position = Vector2.ZERO
	basement_player_position = Vector2.ZERO
	energy = 100
	sleep = 48
	game_hours = 8
	game_minutes = 0
	game_day = 1
	game_time_timer = 0.0
	green_sold = 0
	purple_sold = 0
	white_sold = 0
	money_changed.emit()
	seeds_changed.emit()
	inventory_changed.emit()
	card_money_changed.emit()
	energy_changed.emit()
	sleep_changed.emit()
	time_changed.emit()
	suspicion_changed.emit()
	save_game()

func save_game():
	var save_data = {
		"money": money,
		"card_money": card_money,
		"suspicion": suspicion,
		"seeds": seeds,
		"inventory": inventory,
		"unlocked_seeds": unlocked_seeds,
		"unlocked_equipment": unlocked_equipment,
		"forest_crop_data": forest_crop_data,
		"forest_buildings_data": forest_buildings_data,
		"basement_crop_data": basement_crop_data,
		"basement_buildings_data": basement_buildings_data,
		"basement_dirt_data": basement_dirt_data,
		"water_data": water_data,
		"last_map": last_map,
		"player_position_x": player_position.x,
		"player_position_y": player_position.y,
		"basement_player_position_x": basement_player_position.x,
		"basement_player_position_y": basement_player_position.y,
		"energy": energy,
		"sleep": sleep,
		"game_hours": game_hours,
		"game_minutes": game_minutes,
		"game_day": game_day,
		"green_sold": green_sold,
		"purple_sold": purple_sold,
		"white_sold": white_sold
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("[GameManager] Game saved")

func load_game():
	print("[GameManager] Loading game")
	if not FileAccess.file_exists("user://savegame.json"):
		print("[GameManager] No save file, starting new game")
		new_game()
		return
	
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		if data:
			money = data.get("money", 100)
			card_money = data.get("card_money", 0)
			suspicion = data.get("suspicion", 0)
			seeds = data.get("seeds", {"green": 3, "purple": 0, "white": 0})
			inventory = data.get("inventory", [])
			unlocked_seeds = data.get("unlocked_seeds", {"green": true, "purple": false, "white": false})
			unlocked_equipment = data.get("unlocked_equipment", {"graver": false, "dryer": false, "wrapper": false, "laptop": false, "bed": false})
			forest_crop_data = data.get("forest_crop_data", {})
			forest_buildings_data = data.get("forest_buildings_data", {})
			basement_crop_data = data.get("basement_crop_data", {})
			basement_buildings_data = data.get("basement_buildings_data", {})
			basement_dirt_data = data.get("basement_dirt_data", {})
			water_data = data.get("water_data", {})
			if basement_dirt_data == null:
				basement_dirt_data = {}
			last_map = data.get("last_map", "res://maps/forest/forest.tscn")
			player_position.x = data.get("player_position_x", 0.0)
			player_position.y = data.get("player_position_y", 0.0)
			basement_player_position.x = data.get("basement_player_position_x", 0.0)
			basement_player_position.y = data.get("basement_player_position_y", 0.0)
			energy = data.get("energy", 100)
			sleep = data.get("sleep", 48)
			if sleep > 48:
				sleep = 48
			game_hours = data.get("game_hours", 8)
			game_minutes = data.get("game_minutes", 0)
			game_day = data.get("game_day", 1)
			green_sold = data.get("green_sold", 0)
			purple_sold = data.get("purple_sold", 0)
			white_sold = data.get("white_sold", 0)
			
			var converted_inventory = []
			for item in inventory:
				var item_type = item["type"]
				var item_name = item["name"]
				var item_price = item["price"]
				
				match item_type:
					"green_chopped":
						converted_inventory.append({"type": "green_lvl1", "name": "Green Weed Lvl1", "price": 22})
					"green_dried":
						converted_inventory.append({"type": "green_lvl2", "name": "Green Weed Lvl2", "price": 30})
					"green_dried_chopped":
						converted_inventory.append({"type": "green_lvl3", "name": "Green Weed Lvl3", "price": 45})
					"green_wrapped":
						converted_inventory.append({"type": "green_lvl4", "name": "Green Weed Lvl4", "price": 60})
					"purple_chopped":
						converted_inventory.append({"type": "purple_lvl1", "name": "Purple Haze Lvl1", "price": 45})
					"purple_dried":
						converted_inventory.append({"type": "purple_lvl2", "name": "Purple Haze Lvl2", "price": 60})
					"purple_dried_chopped":
						converted_inventory.append({"type": "purple_lvl3", "name": "Purple Haze Lvl3", "price": 90})
					"purple_wrapped":
						converted_inventory.append({"type": "purple_lvl4", "name": "Purple Haze Lvl4", "price": 120})
					"white_chopped":
						converted_inventory.append({"type": "white_lvl1", "name": "White Widow Lvl1", "price": 75})
					"white_dried":
						converted_inventory.append({"type": "white_lvl2", "name": "White Widow Lvl2", "price": 100})
					"white_dried_chopped":
						converted_inventory.append({"type": "white_lvl3", "name": "White Widow Lvl3", "price": 150})
					"white_wrapped":
						converted_inventory.append({"type": "white_lvl4", "name": "White Widow Lvl4", "price": 200})
					_:
						converted_inventory.append(item)
			
			inventory = converted_inventory
			
			if inventory.is_empty():
				inventory = [
					{"type": "laptop", "name": "Laptop", "price": 500},
					{"type": "bed", "name": "Bed", "price": 50},
					{"type": "crop", "name": "Crop", "price": 10},
					{"type": "basement", "name": "Basement", "price": 100}
				]
			
			money_changed.emit()
			seeds_changed.emit()
			inventory_changed.emit()
			card_money_changed.emit()
			energy_changed.emit()
			sleep_changed.emit()
			time_changed.emit()
			suspicion_changed.emit()
			print("[GameManager] Game loaded successfully")
		file.close()
