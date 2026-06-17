extends CanvasLayer

@onready var line_edit = $Panel/LineEdit
@onready var output_text = $Panel/OutputText
@onready var close_button = $Panel/CloseButton

var is_open: bool = false
var player_ref = null
var command_history: Array = []
var history_index: int = -1

func _ready():
	visible = false
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	if output_text:
		output_text.text = "Console ready. Type 'help' for commands.\n"

func _input(event):
	if event.is_action_pressed("console"):
		toggle_console()
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("cancel") and is_open:
		toggle_console()
		get_viewport().set_input_as_handled()
		return
	
	if is_open and event is InputEventKey:
		if event.keycode == KEY_ENTER and event.pressed:
			var text = line_edit.text
			if text.strip_edges() != "":
				command_history.append(text)
				history_index = -1
				_add_output_line("> " + text)
				execute_command(text)
			else:
				_add_output_line("> (empty)")
				_add_output_line("Enter a command. Type 'help' for commands.")
			line_edit.clear()
			line_edit.grab_focus()
			get_viewport().set_input_as_handled()
			return
		
		if event.keycode == KEY_UP and event.pressed:
			if command_history.size() > 0:
				if history_index == -1:
					history_index = command_history.size() - 1
				elif history_index > 0:
					history_index -= 1
				line_edit.text = command_history[history_index]
				line_edit.caret_column = line_edit.text.length()
			get_viewport().set_input_as_handled()
			return
		
		if event.keycode == KEY_DOWN and event.pressed:
			if command_history.size() > 0 and history_index != -1:
				if history_index < command_history.size() - 1:
					history_index += 1
					line_edit.text = command_history[history_index]
				else:
					history_index = -1
					line_edit.text = ""
				line_edit.caret_column = line_edit.text.length()
			get_viewport().set_input_as_handled()
			return

func _add_output_line(text: String):
	if output_text:
		output_text.text += text + "\n"
		output_text.scroll_to_line(output_text.get_line_count() - 1)

func toggle_console():
	is_open = !is_open
	visible = is_open
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_ref = player
		if is_open:
			player.set_process_input(false)
			player.set_physics_process(false)
			player.set_process_unhandled_input(false)
		else:
			player.set_process_input(true)
			player.set_physics_process(true)
			player.set_process_unhandled_input(true)
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		if is_open:
			ui.set_process_input(false)
			ui.set_process_unhandled_input(false)
		else:
			ui.set_process_input(true)
			ui.set_process_unhandled_input(true)
	
	var forest = get_tree().current_scene
	if forest:
		if is_open:
			forest.set_process_input(false)
			forest.set_process_unhandled_input(false)
		else:
			forest.set_process_input(true)
			forest.set_process_unhandled_input(true)
	
	if is_open:
		history_index = -1
		line_edit.grab_focus()
	else:
		line_edit.clear()

func execute_command(text: String):
	var parts = text.split(" ")
	var command = parts[0].to_lower()
	
	match command:
		"help":
			_add_output_line("=== COMMANDS ===")
			_add_output_line("")
			_add_output_line("--- Money & Resources ---")
			_add_output_line("  add_money <amount> - Add cash")
			_add_output_line("  remove_money <amount> - Remove cash")
			_add_output_line("  add_card_money <amount> - Add card money")
			_add_output_line("  remove_card_money <amount> - Remove card money")
			_add_output_line("  add_energy <amount> - Add energy")
			_add_output_line("  remove_energy <amount> - Remove energy")
			_add_output_line("  add_sleep <amount> - Add sleep")
			_add_output_line("  remove_sleep <amount> - Remove sleep")
			_add_output_line("  add_water <amount> - Add water")
			_add_output_line("  remove_water <amount> - Remove water")
			_add_output_line("")
			_add_output_line("--- Give Items (Products & Buildings) ---")
			_add_output_line("  give_green - Green Weed ($15)")
			_add_output_line("  give_green_lvl1 - Green Weed Lvl1 ($22)")
			_add_output_line("  give_green_lvl2 - Green Weed Lvl2 ($30)")
			_add_output_line("  give_green_lvl3 - Green Weed Lvl3 ($45)")
			_add_output_line("  give_purple - Purple Haze ($30)")
			_add_output_line("  give_purple_lvl1 - Purple Haze Lvl1 ($45)")
			_add_output_line("  give_purple_lvl2 - Purple Haze Lvl2 ($60)")
			_add_output_line("  give_purple_lvl3 - Purple Haze Lvl3 ($90)")
			_add_output_line("  give_white - White Widow ($50)")
			_add_output_line("  give_white_lvl1 - White Widow Lvl1 ($75)")
			_add_output_line("  give_white_lvl2 - White Widow Lvl2 ($100)")
			_add_output_line("  give_white_lvl3 - White Widow Lvl3 ($150)")
			_add_output_line("  give_tin_can - Tin Can ($1)")
			_add_output_line("  give_old_coin - Old Coin ($50)")
			_add_output_line("  give_crystal - Crystal ($100)")
			_add_output_line("")
			_add_output_line("--- Give Buildings ---")
			_add_output_line("  give_crop - Crop ($10)")
			_add_output_line("  give_well - Well ($25)")
			_add_output_line("  give_pc - PC")
			_add_output_line("  give_atm - ATM")
			_add_output_line("  give_basement - Basement ($100)")
			_add_output_line("  give_bed - Bed ($50)")
			_add_output_line("  give_laptop - Laptop ($500)")
			_add_output_line("  give_graver - Graver ($100)")
			_add_output_line("  give_dryer - Dryer ($200)")
			_add_output_line("  give_wrapper - Wrapper ($300)")
			_add_output_line("")
			_add_output_line("--- Give Seeds ---")
			_add_output_line("  give_green_seed - Green Weed Seeds")
			_add_output_line("  give_purple_seed - Purple Haze Seeds")
			_add_output_line("  give_white_seed - White Widow Seeds")
			_add_output_line("")
			_add_output_line("--- Unlock ---")
			_add_output_line("  unlock_seed <green/purple/white> - Unlock seed")
			_add_output_line("  unlock_equip <graver/dryer/wrapper/laptop/bed> - Unlock equipment")
			_add_output_line("")
			_add_output_line("--- Time & Game ---")
			_add_output_line("  time <hour> <minute> - Set time")
			_add_output_line("  day <day> - Set day")
			_add_output_line("  clear - Clear output")
			_add_output_line("  close - Close console")
		
		"add_money":
			if parts.size() > 1:
				var amount = int(parts[1])
				GameManager.add_money(amount)
				_add_output_line("Added $" + str(amount) + " cash")
			else:
				_add_output_line("Usage: add_money <amount>")
		
		"remove_money":
			if parts.size() > 1:
				var amount = int(parts[1])
				if GameManager.spend_money(amount):
					_add_output_line("Removed $" + str(amount) + " cash")
				else:
					_add_output_line("Not enough cash")
			else:
				_add_output_line("Usage: remove_money <amount>")
		
		"add_card_money":
			if parts.size() > 1:
				var amount = int(parts[1])
				GameManager.add_card_money(amount)
				_add_output_line("Added $" + str(amount) + " to card")
			else:
				_add_output_line("Usage: add_card_money <amount>")
		
		"remove_card_money":
			if parts.size() > 1:
				var amount = int(parts[1])
				if GameManager.spend_card_money(amount):
					_add_output_line("Removed $" + str(amount) + " from card")
				else:
					_add_output_line("Not enough card money")
			else:
				_add_output_line("Usage: remove_card_money <amount>")
		
		"add_energy":
			if parts.size() > 1:
				var amount = int(parts[1])
				GameManager.restore_energy(amount)
				_add_output_line("Added " + str(amount) + " energy")
			else:
				_add_output_line("Usage: add_energy <amount>")
		
		"remove_energy":
			if parts.size() > 1:
				var amount = int(parts[1])
				if GameManager.use_energy(amount):
					_add_output_line("Removed " + str(amount) + " energy")
				else:
					_add_output_line("Not enough energy")
			else:
				_add_output_line("Usage: remove_energy <amount>")
		
		"add_sleep":
			if parts.size() > 1:
				var amount = int(parts[1])
				GameManager.sleep = min(GameManager.sleep + amount, GameManager.max_sleep)
				GameManager.sleep_changed.emit()
				_add_output_line("Added " + str(amount) + " sleep, now " + str(GameManager.sleep))
			else:
				_add_output_line("Usage: add_sleep <amount>")
		
		"remove_sleep":
			if parts.size() > 1:
				var amount = int(parts[1])
				GameManager.sleep = max(GameManager.sleep - amount, 0)
				GameManager.sleep_changed.emit()
				_add_output_line("Removed " + str(amount) + " sleep, now " + str(GameManager.sleep))
			else:
				_add_output_line("Usage: remove_sleep <amount>")
		
		"add_water":
			if parts.size() > 1:
				var amount = int(parts[1])
				var forest = get_tree().current_scene
				if forest and forest.has_method("get_current_water") and forest.has_method("get_max_water"):
					var current = forest.get_current_water()
					var max_water = forest.get_max_water()
					var new_water = min(current + amount, max_water)
					var added = new_water - current
					for i in range(added):
						forest.water_manager.current_water_units += 1
					forest.water_manager.save_water_state()
					forest.water_manager.water_changed.emit(forest.get_current_water(), max_water)
					_add_output_line("Added " + str(added) + " water (now " + str(forest.get_current_water()) + "/" + str(max_water) + ")")
				else:
					_add_output_line("Cannot add water here")
			else:
				_add_output_line("Usage: add_water <amount>")
		
		"remove_water":
			if parts.size() > 1:
				var amount = int(parts[1])
				var forest = get_tree().current_scene
				if forest and forest.has_method("get_current_water"):
					var current = forest.get_current_water()
					var new_water = max(current - amount, 0)
					var removed = current - new_water
					for i in range(removed):
						forest.water_manager.current_water_units -= 1
					forest.water_manager.save_water_state()
					forest.water_manager.water_changed.emit(forest.get_current_water(), forest.get_max_water())
					_add_output_line("Removed " + str(removed) + " water (now " + str(forest.get_current_water()) + "/" + str(forest.get_max_water()) + ")")
				else:
					_add_output_line("Cannot remove water here")
			else:
				_add_output_line("Usage: remove_water <amount>")
		
		"give_green":
			GameManager.add_inventory_item({"type": "green", "name": "Green Weed", "price": 15})
			_add_output_line("Gave Green Weed ($15)")
		"give_green_lvl1":
			GameManager.add_inventory_item({"type": "green_lvl1", "name": "Green Weed Lvl1", "price": 22})
			_add_output_line("Gave Green Weed Lvl1 ($22)")
		"give_green_lvl2":
			GameManager.add_inventory_item({"type": "green_lvl2", "name": "Green Weed Lvl2", "price": 30})
			_add_output_line("Gave Green Weed Lvl2 ($30)")
		"give_green_lvl3":
			GameManager.add_inventory_item({"type": "green_lvl3", "name": "Green Weed Lvl3", "price": 45})
			_add_output_line("Gave Green Weed Lvl3 ($45)")
		"give_purple":
			GameManager.add_inventory_item({"type": "purple", "name": "Purple Haze", "price": 30})
			_add_output_line("Gave Purple Haze ($30)")
		"give_purple_lvl1":
			GameManager.add_inventory_item({"type": "purple_lvl1", "name": "Purple Haze Lvl1", "price": 45})
			_add_output_line("Gave Purple Haze Lvl1 ($45)")
		"give_purple_lvl2":
			GameManager.add_inventory_item({"type": "purple_lvl2", "name": "Purple Haze Lvl2", "price": 60})
			_add_output_line("Gave Purple Haze Lvl2 ($60)")
		"give_purple_lvl3":
			GameManager.add_inventory_item({"type": "purple_lvl3", "name": "Purple Haze Lvl3", "price": 90})
			_add_output_line("Gave Purple Haze Lvl3 ($90)")
		"give_white":
			GameManager.add_inventory_item({"type": "white", "name": "White Widow", "price": 50})
			_add_output_line("Gave White Widow ($50)")
		"give_white_lvl1":
			GameManager.add_inventory_item({"type": "white_lvl1", "name": "White Widow Lvl1", "price": 75})
			_add_output_line("Gave White Widow Lvl1 ($75)")
		"give_white_lvl2":
			GameManager.add_inventory_item({"type": "white_lvl2", "name": "White Widow Lvl2", "price": 100})
			_add_output_line("Gave White Widow Lvl2 ($100)")
		"give_white_lvl3":
			GameManager.add_inventory_item({"type": "white_lvl3", "name": "White Widow Lvl3", "price": 150})
			_add_output_line("Gave White Widow Lvl3 ($150)")
		"give_tin_can":
			GameManager.add_inventory_item({"type": "tin_can", "name": "Tin Can", "price": 1})
			_add_output_line("Gave Tin Can ($1)")
		"give_old_coin":
			GameManager.add_inventory_item({"type": "old_coin", "name": "Old Coin", "price": 50})
			_add_output_line("Gave Old Coin ($50)")
		"give_crystal":
			GameManager.add_inventory_item({"type": "crystal", "name": "Crystal", "price": 100})
			_add_output_line("Gave Crystal ($100)")
		"give_crop":
			GameManager.add_inventory_item({"type": "crop", "name": "Crop", "price": 10})
			_add_output_line("Gave Crop ($10)")
		"give_well":
			GameManager.add_inventory_item({"type": "well", "name": "Well", "price": 25})
			_add_output_line("Gave Well ($25)")
		"give_pc":
			GameManager.add_inventory_item({"type": "pc", "name": "PC", "price": 0})
			_add_output_line("Gave PC")
		"give_atm":
			GameManager.add_inventory_item({"type": "atm", "name": "ATM", "price": 0})
			_add_output_line("Gave ATM")
		"give_basement":
			GameManager.add_inventory_item({"type": "basement", "name": "Basement", "price": 100})
			_add_output_line("Gave Basement ($100)")
		"give_bed":
			GameManager.add_inventory_item({"type": "bed", "name": "Bed", "price": 50})
			_add_output_line("Gave Bed ($50)")
		"give_laptop":
			GameManager.add_inventory_item({"type": "laptop", "name": "Laptop", "price": 500})
			_add_output_line("Gave Laptop ($500)")
		"give_graver":
			GameManager.add_inventory_item({"type": "graver", "name": "Graver", "price": 100})
			_add_output_line("Gave Graver ($100)")
		"give_dryer":
			GameManager.add_inventory_item({"type": "dryer", "name": "Dryer", "price": 200})
			_add_output_line("Gave Dryer ($200)")
		"give_wrapper":
			GameManager.add_inventory_item({"type": "wrapper", "name": "Wrapper", "price": 300})
			_add_output_line("Gave Wrapper ($300)")
		"give_green_seed":
			GameManager.add_seeds("green", 1)
			_add_output_line("Gave 1 Green Weed Seed")
		"give_purple_seed":
			GameManager.add_seeds("purple", 1)
			_add_output_line("Gave 1 Purple Haze Seed")
		"give_white_seed":
			GameManager.add_seeds("white", 1)
			_add_output_line("Gave 1 White Widow Seed")
		
		"unlock_seed":
			if parts.size() > 1:
				var seed_type = parts[1].to_lower()
				if seed_type in ["green", "purple", "white"]:
					GameManager.unlock_seed(seed_type)
					_add_output_line("Unlocked " + seed_type + " seeds")
				else:
					_add_output_line("Unknown seed type: " + seed_type)
			else:
				_add_output_line("Usage: unlock_seed <green/purple/white>")
		
		"unlock_equip":
			if parts.size() > 1:
				var equip_type = parts[1].to_lower()
				if equip_type in ["graver", "dryer", "wrapper", "laptop", "bed"]:
					GameManager.unlock_equipment(equip_type)
					_add_output_line("Unlocked " + equip_type)
				else:
					_add_output_line("Unknown equipment: " + equip_type)
			else:
				_add_output_line("Usage: unlock_equip <graver/dryer/wrapper/laptop/bed>")
		
		"time":
			if parts.size() > 2:
				var hour = int(parts[1])
				var minute = int(parts[2])
				if hour >= 0 and hour < 24 and minute >= 0 and minute < 60:
					GameManager.game_hours = hour
					GameManager.game_minutes = minute
					GameManager.time_changed.emit()
					_add_output_line("Time set to " + str(hour).pad_zeros(2) + ":" + str(minute).pad_zeros(2))
				else:
					_add_output_line("Invalid time")
			else:
				_add_output_line("Usage: time <hour> <minute>")
		
		"day":
			if parts.size() > 1:
				var day = int(parts[1])
				if day > 0:
					GameManager.game_day = day
					GameManager.time_changed.emit()
					_add_output_line("Day set to " + str(day))
				else:
					_add_output_line("Day must be positive")
			else:
				_add_output_line("Usage: day <day>")
		
		"clear":
			if output_text:
				output_text.text = "Console cleared.\n"
			_add_output_line("Console cleared.")
		
		"close":
			_add_output_line("Closing console...")
			toggle_console()
		
		_:
			_add_output_line("Unknown command: " + command + ". Type 'help' for commands.")

func _on_close_pressed():
	toggle_console()
