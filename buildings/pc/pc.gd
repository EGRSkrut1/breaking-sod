extends Area2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var interact_label = $Label

var cell_pos: Vector2 = Vector2.ZERO
var loaded_from_save: bool = false

# Initializes PC building
func _ready():
	add_to_group("buildings")
	add_to_group("pcs")
	add_to_group("seed_shops")
	
	print("[PC] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Open Computer"

# Sets grid position for save system
func set_cell_pos(pos: Vector2):
	cell_pos = pos

# Returns grid position for save system
func get_cell_pos() -> Vector2:
	return cell_pos

# Marks this building as loaded from save (not editor-placed)
func set_loaded_from_save():
	loaded_from_save = true

# Returns true if building was placed in editor
func is_editor_placed() -> bool:
	return not loaded_from_save

# Returns save data for persistence
func get_save_data() -> Dictionary:
	return {
		"type": "pc",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

# Called when player interacts with PC
func interact():
	print("[PC] Interact called")
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("[PC] Player not found")
		return
	
	var dist = global_position.distance_to(player.global_position)
	print("[PC] Distance to player: ", dist)
	if dist > 50:
		print("[PC] Too far")
		return
	
	open_computer_ui()

# Opens the computer UI
func open_computer_ui():
	print("[PC] Opening Computer UI")
	
	var computer_ui = get_tree().current_scene.get_node_or_null("ComputerUI")
	if not computer_ui:
		computer_ui = get_node("/root/Main/ComputerUI")
	
	if computer_ui:
		print("[PC] ComputerUI found")
		computer_ui.visible = true
		computer_ui.set_shop_data(get_shop_data(), self)
	else:
		print("[PC] ERROR: ComputerUI not found")

# Returns available seeds in shop (bed locked by default)
func get_shop_data() -> Dictionary:
	return {
		"green": {
			"name": "Green Weed Seeds",
			"price": 10,
			"description": "Fast growth, low sell price",
			"unlocked": true
		},
		"purple": {
			"name": "Purple Haze Seeds",
			"price": 25,
			"description": "Medium growth, good price",
			"unlocked": GameManager.unlocked_seeds.get("purple", false)
		},
		"white": {
			"name": "White Widow Seeds",
			"price": 50,
			"description": "Slow growth, high price",
			"unlocked": GameManager.unlocked_seeds.get("white", false)
		}
	}

# Handles seed purchase
func buy_seed(seed_type: String, quantity: int = 1) -> bool:
	var shop_data = get_shop_data()
	if not shop_data.has(seed_type):
		print("[PC] Seed type not found: ", seed_type)
		return false
	
	if not shop_data[seed_type]["unlocked"]:
		print("[PC] Seed type locked: ", seed_type)
		return false
	
	var total_cost = shop_data[seed_type]["price"] * quantity
	print("[PC] Total cost: ", total_cost)
	
	if GameManager.spend_card_money(total_cost):
		GameManager.add_seeds(seed_type, quantity)
		print("[PC] Bought ", quantity, "x ", seed_type)
		return true
	
	print("[PC] Not enough card money")
	return false

# Shows interact label when player enters
func _on_body_entered(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = true
		print("[PC] Body entered: ", body.name)

# Hides interact label when player exits
func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
		print("[PC] Body exited: ", body.name)
