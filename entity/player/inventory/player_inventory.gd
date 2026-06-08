extends Node
class_name PlayerInventory

var selected_seed: String = "green"

# Initializes inventory component
func setup():
	print("[PlayerInventory] Setup complete")

# Sets currently selected seed type
func set_selected_seed(seed_type: String):
	selected_seed = seed_type
	print("[PlayerInventory] Selected seed: ", selected_seed)

# Returns currently selected seed type
func get_selected_seed() -> String:
	return selected_seed
