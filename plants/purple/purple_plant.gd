extends BasePlant
class_name PurplePlant


# Sets purple plant specific growth parameters
func set_plant_data():
	required_water = 2
	growth_time = 90.0


# Returns display name of the plant
func get_plant_name() -> String:
	return "Purple Haze"


# Returns sell price (30 when mature, 0 otherwise)
func get_sell_value() -> int:
	return 30 if is_mature else 0


# Returns growth target based on water count (two-stage plant)
func get_progress_target() -> float:
	if water_count == 1:
		return 0.5
	return 1.0


# Returns starting progress for current growth phase
func get_progress_start() -> float:
	if water_count == 1:
		return 0.0
	return 0.5


# Plays water drop animation on the water icon
func play_water_animation():
	if water_icon and water_icon is AnimatedSprite2D:
		water_icon.visible = true
		water_icon.play("watered soil")
		await get_tree().create_timer(1.0).timeout
		water_icon.visible = false
