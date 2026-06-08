extends Node
class_name SaveLoadManager

signal crops_loaded
signal buildings_loaded

var parent_node: Node2D = null
var crop_data_source: String = "forest"
var buildings_data_source: String = "forest"
var water_data_source: String = "forest"

func setup(parent: Node2D):
	parent_node = parent
	print("[SaveLoadManager] Setup complete")

func set_crop_data_source(source: String):
	crop_data_source = source

func set_buildings_data_source(source: String):
	buildings_data_source = source

func set_water_data_source(source: String):
	water_data_source = source

func save_all_crops(grid_manager: GridManager):
	var crop_save_data = {}
	for crop_data_item in grid_manager.get_all_crops():
		var x = crop_data_item["x"]
		var y = crop_data_item["y"]
		var crop = crop_data_item["crop"]
		var key = str(x) + "," + str(y)
		crop_save_data[key] = {
			"has_crop": true,
			"has_plant": crop.is_planted,
			"is_watered": crop.is_watered
		}
		if crop.is_planted and crop.current_plant:
			crop_save_data[key]["plant_type"] = crop.current_plant.plant_type
			crop_save_data[key]["water_count"] = crop.current_plant.water_count
			crop_save_data[key]["current_stage"] = crop.current_plant.current_stage
			crop_save_data[key]["overall_progress"] = crop.current_plant.overall_progress
			crop_save_data[key]["is_mature"] = crop.current_plant.is_mature
			crop_save_data[key]["required_water"] = crop.current_plant.required_water
			crop_save_data[key]["growth_time"] = crop.current_plant.growth_time
			crop_save_data[key]["last_water_time"] = crop.current_plant.last_water_time
	
	if crop_data_source == "forest":
		GameManager.save_forest_crop_data(crop_save_data)
	else:
		GameManager.save_basement_crop_data(crop_save_data)
	print("[SaveLoadManager] Crops saved: ", crop_save_data.size())

func save_all_buildings():
	var buildings_data = {}
	var buildings = parent_node.get_tree().get_nodes_in_group("buildings")
	for building in buildings:
		if building.has_method("get_save_data"):
			var save_data = building.get_save_data()
			var key = str(save_data["position_x"]) + "," + str(save_data["position_y"])
			buildings_data[key] = save_data
			print("[SaveLoadManager] Saved building: ", save_data["type"])
	
	if buildings_data_source == "forest":
		GameManager.save_forest_buildings_data(buildings_data)
	else:
		GameManager.save_basement_buildings_data(buildings_data)
	print("[SaveLoadManager] Buildings saved: ", buildings_data.size())

func load_crops(grid_manager: GridManager, add_crop_func: Callable):
	var saved_crops = {}
	if crop_data_source == "forest":
		saved_crops = GameManager.get_forest_crop_data()
	else:
		saved_crops = GameManager.get_basement_crop_data()
	
	print("[SaveLoadManager] Loading crops from ", crop_data_source, ": ", saved_crops.size())
	
	for crop_key in saved_crops:
		var coords = crop_key.split(",")
		if coords.size() == 2:
			var x = int(coords[0])
			var y = int(coords[1])
			var crop_info = saved_crops[crop_key]
			add_crop_func.call(x, y)
			var crop = grid_manager.get_cell(x, y)
			if crop_info.has("has_plant") and crop_info.has_plant:
				crop.plant_seed(crop_info.plant_type)
				await parent_node.get_tree().process_frame
				if crop.current_plant:
					var saved_progress = crop_info.get("overall_progress", 0.0)
					var saved_stage = crop_info.get("current_stage", 0)
					var saved_water = crop_info.get("water_count", 0)
					var saved_mature = crop_info.get("is_mature", false)
					var saved_last_water = crop_info.get("last_water_time", Time.get_ticks_msec() / 1000.0)
					if crop.current_plant.has_method("restore_from_save"):
						crop.current_plant.restore_from_save(saved_progress, saved_stage, saved_water, saved_mature, saved_last_water)
	crops_loaded.emit()
	print("[SaveLoadManager] Crops loaded")

func load_buildings(add_building_func: Callable):
	var saved_buildings = {}
	if buildings_data_source == "forest":
		saved_buildings = GameManager.get_forest_buildings_data()
	else:
		saved_buildings = GameManager.get_basement_buildings_data()
	
	print("[SaveLoadManager] Loading buildings from ", buildings_data_source, ": ", saved_buildings.size())
	
	for building_key in saved_buildings:
		var building_info = saved_buildings[building_key]
		var x = building_info.get("position_x", 0)
		var y = building_info.get("position_y", 0)
		var building_type = building_info.get("type", "")
		add_building_func.call(x, y, building_type)
	buildings_loaded.emit()
	print("[SaveLoadManager] Buildings loaded")
