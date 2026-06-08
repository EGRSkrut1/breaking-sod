extends Node
class_name PlantManager

# Creates plant instance of specified type
static func create_plant(plant_type: String) -> Node:
	var path = "res://plants/base/base_plant.tscn"
	if not FileAccess.file_exists(path):
		print("[PlantManager] Failed to load base_plant.tscn")
		return null
	
	var plant_scene = load(path)
	if not plant_scene:
		print("[PlantManager] Failed to load plant scene")
		return null
	
	var plant = plant_scene.instantiate()
	
	match plant_type:
		"green":
			var green_script = load("res://plants/green/green_plant.gd")
			if green_script:
				plant.set_script(green_script)
				if plant.has_method("set_type"):
					plant.set_type(plant_type)
		"purple":
			var purple_script = load("res://plants/purple/purple_plant.gd")
			if purple_script:
				plant.set_script(purple_script)
				if plant.has_method("set_type"):
					plant.set_type(plant_type)
		"white":
			var white_script = load("res://plants/white/white_plant.gd")
			if white_script:
				plant.set_script(white_script)
				if plant.has_method("set_type"):
					plant.set_type(plant_type)
		_:
			print("[PlantManager] Unknown plant type: ", plant_type)
			return null
	
	print("[PlantManager] Created plant: ", plant_type)
	return plant
