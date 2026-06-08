extends Node
class_name PlayerInteraction

var player: CharacterBody2D = null
var interact_range: float = 48.0
var interacting: bool = false

# Sets up the interaction component
func setup(player_node: CharacterBody2D):
	player = player_node
	print("[PlayerInteraction] Setup complete")

# Handles interaction input
func process_input(event):
	if event.is_action_pressed("interact"):
		print("[PlayerInteraction] Interact action pressed")
		interact_with_crop()
		interact_with_building()
		interact_with_customer()
	
	if event.is_action_pressed("console"):
		toggle_console()

# Interacts with crop under mouse cursor
func interact_with_crop():
	print("[PlayerInteraction] interact_with_crop called")
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("get_crop_at_mouse"):
		var crop = main_node.get_crop_at_mouse()
		if crop and crop.is_planted and crop.current_plant:
			var dist = player.global_position.distance_to(crop.global_position)
			print("[PlayerInteraction] Distance to crop: ", dist)
			if dist < interact_range:
				if crop.current_plant.is_ready_to_harvest():
					print("[PlayerInteraction] Harvesting crop")
					crop.harvest()
				else:
					print("[PlayerInteraction] Plant not ready to harvest")
			else:
				print("[PlayerInteraction] Crop too far")
		else:
			print("[PlayerInteraction] No crop at mouse position")

# Finds and interacts with nearest building
func interact_with_building():
	print("[PlayerInteraction] interact_with_building called")
	var buildings = get_tree().get_nodes_in_group("buildings")
	var nearest_building = null
	var nearest_dist = 50.0
	
	print("[PlayerInteraction] Found buildings: ", buildings.size())
	
	for building in buildings:
		var dist = player.global_position.distance_to(building.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_building = building
	
	if nearest_building and nearest_building.has_method("interact"):
		print("[PlayerInteraction] Interacting with: ", nearest_building.name)
		interacting = true
		nearest_building.interact()
		await get_tree().create_timer(0.5).timeout
		interacting = false
	else:
		print("[PlayerInteraction] No building in range")

# Finds and interacts with nearest customer
func interact_with_customer():
	print("[PlayerInteraction] interact_with_customer called")
	var customers = get_tree().get_nodes_in_group("customers")
	var nearest_customer = null
	var nearest_dist = 50.0
	
	for customer in customers:
		var dist = player.global_position.distance_to(customer.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_customer = customer
	
	if nearest_customer and nearest_customer.has_method("interact"):
		print("[PlayerInteraction] Interacting with customer: ", nearest_customer.name)
		nearest_customer.interact()

# Toggles debug console
func toggle_console():
	var console = get_tree().current_scene.get_node_or_null("Console")
	if console:
		console.visible = !console.visible
		print("[PlayerInteraction] Console toggled, visible: ", console.visible)
