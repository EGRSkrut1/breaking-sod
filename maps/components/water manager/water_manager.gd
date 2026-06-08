extends Node
class_name WaterManager

signal water_changed(current, max)
signal water_refilled

var max_water_units: int = 50
var current_water_units: int = 50
var water_per_use: int = 10

func load_water_from_save():
	var water_data = GameManager.get_water_data()
	if water_data and water_data.size() > 0:
		max_water_units = water_data.get("max_water_units", 50)
		current_water_units = water_data.get("current_water_units", 50)
		water_changed.emit(current_water_units, max_water_units)
		print("[WaterManager] Loaded water: ", current_water_units, "/", max_water_units)

func save_water_state():
	var water_data = {
		"max_water_units": max_water_units,
		"current_water_units": current_water_units
	}
	GameManager.save_water_data(water_data)
	print("[WaterManager] Saved water: ", current_water_units, "/", max_water_units)

func use_water() -> bool:
	if current_water_units >= water_per_use:
		current_water_units -= water_per_use
		water_changed.emit(current_water_units, max_water_units)
		save_water_state()
		print("[WaterManager] Used water, remaining: ", current_water_units)
		return true
	print("[WaterManager] Not enough water")
	return false

func refill_water():
	if current_water_units < max_water_units:
		var old_water = current_water_units
		current_water_units = max_water_units
		water_changed.emit(current_water_units, max_water_units)
		water_refilled.emit()
		save_water_state()
		
		var main_node = get_tree().current_scene
		var ui = main_node.get_node_or_null("UI") if main_node else null
		if ui and ui.has_method("show_floating_text"):
			var well = main_node.get_node_or_null("Well")
			var pos = well.global_position if well else Vector2.ZERO
			var added = current_water_units - old_water
			ui.show_floating_text("+" + str(added), Color(0.2, 0.5, 0.8, 1), pos)
		print("[WaterManager] Refilled water: ", current_water_units)
	else:
		var main_node = get_tree().current_scene
		var ui = main_node.get_node_or_null("UI") if main_node else null
		if ui and ui.has_method("show_floating_text"):
			var well = main_node.get_node_or_null("Well")
			var pos = well.global_position if well else Vector2.ZERO
			ui.show_floating_text("FULL", Color(1, 0.5, 0, 1), pos)
		print("[WaterManager] Water already full")

func upgrade_capacity(amount: int):
	max_water_units += amount
	current_water_units = max_water_units
	water_changed.emit(current_water_units, max_water_units)
	save_water_state()
	print("[WaterManager] Upgraded capacity to: ", max_water_units)

func reduce_water_per_use(new_amount: int):
	water_per_use = new_amount
	print("[WaterManager] Reduced water per use to: ", water_per_use)

func get_water_percent() -> float:
	return float(current_water_units) / float(max_water_units) * 100.0

func get_current_water() -> int:
	return current_water_units

func get_max_water() -> int:
	return max_water_units
