extends Area2D

var items_for_drying: Array = []
var dry_progress: float = 0.0
var dry_time: float = 8.0
var is_drying: bool = false
var cell_pos: Vector2 = Vector2.ZERO
var player_ref = null

@onready var anim_sprite = $AnimatedSprite2D
@onready var progress_bar = $ProgressBar
@onready var interact_label = $Label

func _ready():
	add_to_group("buildings")
	add_to_group("dryers")
	print("[Dryer] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if progress_bar:
		progress_bar.visible = false
		progress_bar.max_value = dry_time
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Dry Plant"

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func get_save_data() -> Dictionary:
	return {
		"type": "dryer",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

func _process(delta):
	if is_drying and items_for_drying.size() > 0:
		dry_progress += delta
		if progress_bar:
			progress_bar.value = dry_progress
		if dry_progress >= dry_time:
			dry_current_item()

func add_item(item_data: Dictionary):
	if items_for_drying.size() >= 5:
		return
	items_for_drying.append(item_data)
	if not is_drying:
		start_drying()

func start_drying():
	if items_for_drying.size() == 0:
		return
	is_drying = true
	dry_progress = 0.0
	if progress_bar:
		progress_bar.visible = true
	print("[Dryer] Started drying")

func dry_current_item():
	if items_for_drying.size() == 0:
		stop_drying()
		return
	var item = items_for_drying[0]
	
	var dried_item = {}
	var result_name = ""
	match item["type"]:
		"green_lvl1":
			dried_item = {"type": "green_lvl2", "name": "Green Weed Lvl2", "price": 30}
			result_name = "Green Weed Lvl2"
		"purple_lvl1":
			dried_item = {"type": "purple_lvl2", "name": "Purple Haze Lvl2", "price": 60}
			result_name = "Purple Haze Lvl2"
		"white_lvl1":
			dried_item = {"type": "white_lvl2", "name": "White Widow Lvl2", "price": 100}
			result_name = "White Widow Lvl2"
		_:
			stop_drying()
			return
	
	GameManager.add_inventory_item(dried_item)
	items_for_drying.remove_at(0)
	dry_progress = 0.0
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		ui.show_floating_text("+" + result_name, Color(0.2, 0.8, 0.2, 1), global_position + Vector2(0, -40))
	
	stop_drying()
	print("[Dryer] Dried: ", item["name"])

func stop_drying():
	is_drying = false
	if progress_bar:
		progress_bar.visible = false
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref = null
	print("[Dryer] Stopped drying")

func interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		return
	
	player_ref = player
	player_ref.set_physics_process(false)
	
	var item_to_dry = null
	for item in GameManager.inventory:
		if item["type"] in ["green_lvl1", "purple_lvl1", "white_lvl1"]:
			item_to_dry = item
			break
	
	if item_to_dry:
		add_item(item_to_dry)
		GameManager.remove_inventory_item(item_to_dry["type"])
		await get_tree().create_timer(dry_time + 0.1).timeout
	
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref = null
	print("[Dryer] Interacted")

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
