extends BasePlant
class_name GreenPlant


# Sets green plant specific growth parameters
func set_plant_data():
	required_water = 1
	growth_time = 60.0


# Returns display name of the plant
func get_plant_name() -> String:
	return "Green Weed"


# Returns sell price (15 when mature, 0 otherwise)
func get_sell_value() -> int:
	return 15 if is_mature else 0


# Returns growth target (always 100% for green plant)
func get_progress_target() -> float:
	return 1.0


# Returns starting progress (always 0% for green plant)
func get_progress_start() -> float:
	return 0.0


# Plays water drop animation on the water icon
func play_water_animation():
	if water_icon and water_icon is AnimatedSprite2D:
		water_icon.visible = true
		water_icon.play("watered soil")
		await get_tree().create_timer(1.0).timeout
		water_icon.visible = false
