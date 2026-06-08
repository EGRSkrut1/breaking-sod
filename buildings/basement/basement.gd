extends Area2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var interact_label = $Label
var cell_pos: Vector2 = Vector2.ZERO
var is_placed: bool = false

func _ready():
	add_to_group("buildings")
	add_to_group("basements")
	print("[Basement] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Go to Basement"

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func get_save_data() -> Dictionary:
	return {
		"type": "basement",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

func interact():
	print("[Basement] Interact called")
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("[Basement] Player not found")
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		print("[Basement] Too far, distance: ", dist)
		return
	
	if not is_placed:
		var main = get_tree().current_scene
		var basements = main.get_tree().get_nodes_in_group("basements")
		if basements.size() > 1:
			print("[Basement] Only one basement allowed!")
			return
		is_placed = true
	
	go_to_basement()

func go_to_basement():
	print("[Basement] Going to basement")
	
	var current_scene = get_tree().current_scene
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameManager.player_position = player.global_position
		print("[Basement] Player position saved: ", GameManager.player_position)
	
	GameManager.last_map = current_scene.scene_file_path
	print("[Basement] Last map saved: ", GameManager.last_map)
	
	if current_scene.has_method("set_basement_position"):
		current_scene.set_basement_position(global_position)
		print("[Basement] Basement position saved: ", global_position)
	
	var basement_map = load("res://maps/basement/basement_map.tscn").instantiate()
	
	get_tree().root.add_child(basement_map)
	get_tree().current_scene = basement_map
	
	await get_tree().process_frame
	
	current_scene.queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = true
		print("[Basement] Body entered: ", body.name)

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
		print("[Basement] Body exited: ", body.name)
