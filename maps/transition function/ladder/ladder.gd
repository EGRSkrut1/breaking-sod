extends Area2D

var cell_pos: Vector2 = Vector2.ZERO

@onready var anim_sprite = $AnimatedSprite2D
@onready var interact_label = $Label

# Initializes ladder (basement exit)
func _ready():
	add_to_group("buildings")
	add_to_group("ladders")
	
	print("[Ladder] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Go Up"

# Sets grid position for save system
func set_cell_pos(pos: Vector2):
	cell_pos = pos

# Returns grid position for save system
func get_cell_pos() -> Vector2:
	return cell_pos

# Returns save data for persistence
func get_save_data() -> Dictionary:
	return {
		"type": "ladder",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

# Called when player interacts with ladder
func interact():
	print("[Ladder] Going up to main")
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameManager.player_position = player.global_position
		print("[Ladder] Player position saved: ", GameManager.player_position)
	
	var basement_map = get_tree().current_scene
	if basement_map and basement_map.has_method("return_to_main"):
		basement_map.return_to_main()

# Shows interact label only when player is very close
func _on_body_entered(body):
	if body.is_in_group("player") and interact_label:
		var dist = global_position.distance_to(body.global_position)
		if dist < 16:
			interact_label.visible = true
			print("[Ladder] Body entered: ", body.name)

# Hides interact label when player exits
func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
		print("[Ladder] Body exited: ", body.name)
