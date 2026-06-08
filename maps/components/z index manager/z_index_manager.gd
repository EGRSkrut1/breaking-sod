extends Node
class_name ZIndexManager

var player_node = null

func setup(player: Node2D):
	player_node = player
	print("[ZIndexManager] Setup complete")

func update_z_index():
	if not player_node:
		return
	
	player_node.z_index = 100
	
	var player_y = player_node.global_position.y
	
	var grid_manager = get_parent().get_node_or_null("GridManager")
	if not grid_manager:
		return
	
	for crop_data in grid_manager.get_all_crops():
		var crop = crop_data["crop"]
		if not crop:
			continue
		
		var crop_y = crop.global_position.y
		
		# Player is ABOVE crop (player Y smaller) -> player on top, crop behind
		if player_y < crop_y:
			crop.z_index = 150
			if crop.current_plant:
				crop.current_plant.z_index = 140
		# Player is BELOW crop (player Y larger) -> crop on top, player behind
		else:
			crop.z_index = 50
			if crop.current_plant:
				crop.current_plant.z_index = 40

func refresh():
	if player_node:
		update_z_index()

func set_player_z_index(z: int):
	if player_node:
		player_node.z_index = z

func set_crop_z_index(crop, z: int):
	crop.z_index = z

func set_plant_z_index(plant, z: int):
	if plant:
		plant.z_index = z
