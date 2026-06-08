extends Area2D

var items_for_wrapping: Array = []
var wrap_progress: float = 0.0
var wrap_time: float = 10.0
var is_wrapping: bool = false
var cell_pos: Vector2 = Vector2.ZERO
var player_ref = null

@onready var anim_sprite = $AnimatedSprite2D
@onready var progress_bar = $ProgressBar
@onready var interact_label = $Label

func _ready():
	add_to_group("buildings")
	add_to_group("wrappers")
	print("[Wrapper] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if progress_bar:
		progress_bar.visible = false
		progress_bar.max_value = wrap_time
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Wrap Product"

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func get_save_data() -> Dictionary:
	return {
		"type": "wrapper",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

func _process(delta):
	if is_wrapping and items_for_wrapping.size() > 0:
		wrap_progress += delta
		if progress_bar:
			progress_bar.value = wrap_progress
		if wrap_progress >= wrap_time:
			wrap_current_item()

func add_item(item_data: Dictionary):
	if items_for_wrapping.size() >= 5:
		return
	items_for_wrapping.append(item_data)
	if not is_wrapping:
		start_wrapping()

func start_wrapping():
	if items_for_wrapping.size() == 0:
		return
	is_wrapping = true
	wrap_progress = 0.0
	if progress_bar:
		progress_bar.visible = true
	print("[Wrapper] Started wrapping")

func wrap_current_item():
	if items_for_wrapping.size() == 0:
		stop_wrapping()
		return
	var item = items_for_wrapping[0]
	
	var wrapped_item = {}
	var result_name = ""
	match item["type"]:
		"green_lvl2":
			wrapped_item = {"type": "green_lvl3", "name": "Green Weed Lvl3", "price": 45}
			result_name = "Green Weed Lvl3"
		"purple_lvl2":
			wrapped_item = {"type": "purple_lvl3", "name": "Purple Haze Lvl3", "price": 90}
			result_name = "Purple Haze Lvl3"
		"white_lvl2":
			wrapped_item = {"type": "white_lvl3", "name": "White Widow Lvl3", "price": 150}
			result_name = "White Widow Lvl3"
		_:
			stop_wrapping()
			return
	
	GameManager.add_inventory_item(wrapped_item)
	items_for_wrapping.remove_at(0)
	wrap_progress = 0.0
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		ui.show_floating_text("+" + result_name, Color(0.2, 0.8, 0.2, 1), global_position + Vector2(0, -40))
	
	stop_wrapping()
	print("[Wrapper] Wrapped: ", item["name"])

func stop_wrapping():
	is_wrapping = false
	if progress_bar:
		progress_bar.visible = false
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref = null
	print("[Wrapper] Stopped wrapping")

func interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		return
	
	player_ref = player
	player_ref.set_physics_process(false)
	
	var item_to_wrap = null
	for item in GameManager.inventory:
		if item["type"] in ["green_lvl2", "purple_lvl2", "white_lvl2"]:
			item_to_wrap = item
			break
	
	if item_to_wrap:
		add_item(item_to_wrap)
		GameManager.remove_inventory_item(item_to_wrap["type"])
		await get_tree().create_timer(wrap_time + 0.1).timeout
	
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref = null
	print("[Wrapper] Interacted")

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
