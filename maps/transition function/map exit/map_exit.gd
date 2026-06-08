extends Area2D

var cell_pos: Vector2 = Vector2.ZERO
var target_map: String = ""

@onready var anim_sprite = $AnimatedSprite2D
@onready var interact_label = $Label

func _ready():
	add_to_group("buildings")
	add_to_group("map_exits")
	
	print("[MapExit] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Choose Map"

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func set_target_map(map_path: String):
	target_map = map_path
	print("[MapExit] Target map set to: ", target_map)

func get_save_data() -> Dictionary:
	return {
		"type": "map_exit",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y),
		"target_map": target_map
	}

func interact():
	print("[MapExit] Interact called")
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		return
	
	open_map_choice_ui()

func open_map_choice_ui():
	print("[MapExit] Opening Map Choice UI")
	
	var map_choice_ui = get_tree().current_scene.get_node_or_null("MapChoiceUI")
	if not map_choice_ui:
		map_choice_ui = get_node("/root/Main/MapChoiceUI")
	
	if map_choice_ui:
		print("[MapExit] MapChoiceUI found")
		map_choice_ui.visible = true
		map_choice_ui.set_current_map_exit(self)

func change_map(target_map_path: String):
	print("[MapExit] Changing map to: ", target_map_path)
	
	var current_scene = get_tree().current_scene
	var new_scene = load(target_map_path).instantiate()
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameManager.player_position = player.global_position
	
	GameManager.last_map = current_scene.scene_file_path
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene.queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
