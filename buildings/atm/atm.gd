extends Area2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var interact_label = $Label
var cell_pos: Vector2 = Vector2.ZERO
var loaded_from_save: bool = false

# Initializes ATM building
func _ready():
	add_to_group("buildings")
	add_to_group("atms")
	print("[ATM] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Open ATM"

# Sets grid position for save system
func set_cell_pos(pos: Vector2):
	cell_pos = pos

# Returns grid position for save system
func get_cell_pos() -> Vector2:
	return cell_pos

# Marks building as loaded from save
func set_loaded_from_save():
	loaded_from_save = true

# Returns true if placed in editor
func is_editor_placed() -> bool:
	return not loaded_from_save

# Returns save data for persistence
func get_save_data() -> Dictionary:
	return {
		"type": "atm",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

# Called when player interacts with ATM
func interact():
	print("[ATM] Interact called")
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("[ATM] Player not found")
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		print("[ATM] Too far, distance: ", dist)
		return
	
	open_atm_ui()

# Opens ATM user interface
func open_atm_ui():
	print("[ATM] Opening ATM UI")
	
	var atm_ui = get_tree().current_scene.get_node_or_null("AtmUI")
	if not atm_ui:
		atm_ui = get_node("/root/Main/AtmUI")
	
	if atm_ui and atm_ui.has_method("set_atm_ref"):
		print("[ATM] AtmUI found")
		atm_ui.visible = true
		atm_ui.set_atm_ref(self)
	else:
		print("[ATM] ERROR: AtmUI not found or no set_atm_ref method")

# Shows interact label when player enters
func _on_body_entered(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = true
		print("[ATM] Body entered: ", body.name)

# Hides interact label when player exits
func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
		print("[ATM] Body exited: ", body.name)
