extends Area2D

var items_for_processing: Array = []
var process_progress: float = 0.0
var process_time: float = 5.0
var processing_active: bool = false
var cell_pos: Vector2 = Vector2.ZERO
var player_ref = null

@onready var anim_sprite = $AnimatedSprite2D
@onready var progress_bar = $ProgressBar
@onready var interact_label = $Label

func _ready():
	add_to_group("buildings")
	add_to_group("gravers")
	print("[Graver] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if progress_bar:
		progress_bar.visible = false
		progress_bar.max_value = process_time
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Process Plant"

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func get_save_data() -> Dictionary:
	return {
		"type": "graver",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

func _process(delta):
	if processing_active and items_for_processing.size() > 0:
		process_progress += delta
		if progress_bar:
			progress_bar.value = process_progress
		if process_progress >= process_time:
			process_current_item()

func add_item(item_data: Dictionary):
	if items_for_processing.size() >= 5:
		return
	items_for_processing.append(item_data)
	if not processing_active:
		start_processing()

func start_processing():
	if items_for_processing.size() == 0:
		return
	processing_active = true
	process_progress = 0.0
	if progress_bar:
		progress_bar.visible = true
	print("[Graver] Started processing")

func process_current_item():
	if items_for_processing.size() == 0:
		stop_processing()
		return
	var item = items_for_processing[0]
	
	var processed_item = {}
	var result_name = ""
	match item["type"]:
		"green":
			processed_item = {"type": "green_lvl1", "name": "Green Weed Lvl1", "price": 22}
			result_name = "Green Weed Lvl1"
		"purple":
			processed_item = {"type": "purple_lvl1", "name": "Purple Haze Lvl1", "price": 45}
			result_name = "Purple Haze Lvl1"
		"white":
			processed_item = {"type": "white_lvl1", "name": "White Widow Lvl1", "price": 75}
			result_name = "White Widow Lvl1"
		_:
			stop_processing()
			return
	
	GameManager.add_inventory_item(processed_item)
	items_for_processing.remove_at(0)
	process_progress = 0.0
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		ui.show_floating_text("+" + result_name, Color(0.2, 0.8, 0.2, 1), global_position + Vector2(0, -40))
	
	stop_processing()
	print("[Graver] Processed: ", item["name"])

func stop_processing():
	processing_active = false
	if progress_bar:
		progress_bar.visible = false
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref = null
	print("[Graver] Stopped processing")

func interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		return
	
	player_ref = player
	player_ref.set_physics_process(false)
	
	var plant_to_process = null
	for item in GameManager.inventory:
		if item["type"] in ["green", "purple", "white"]:
			plant_to_process = item
			break
	
	if plant_to_process:
		add_item(plant_to_process)
		GameManager.remove_inventory_item(plant_to_process["type"])
		await get_tree().create_timer(process_time + 0.1).timeout
	
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref = null
	print("[Graver] Interacted")

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
