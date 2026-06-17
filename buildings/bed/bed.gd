extends Area2D

var cell_pos: Vector2 = Vector2.ZERO
var is_using: bool = false
var player_ref = null

@onready var anim_sprite = $AnimatedSprite2D
@onready var interact_label = $Label
@onready var progress_bar = $ProgressBar

func _ready():
	add_to_group("buildings")
	add_to_group("beds")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Sleep"
	
	if progress_bar:
		progress_bar.visible = false
		progress_bar.min_value = 0
		progress_bar.max_value = 100
		progress_bar.value = 0

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func get_save_data() -> Dictionary:
	return {
		"type": "bed",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

func interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		return
	
	if is_using:
		return
	
	if GameManager.sleep >= 40:
		var ui = get_tree().current_scene.get_node_or_null("UI")
		if ui and ui.has_method("show_floating_text"):
			ui.show_floating_text("Not tired yet", Color(1, 0.5, 0, 1), global_position)
		return
	
	start_sleeping(player)

func start_sleeping(player):
	print("[Bed] Start sleeping")
	is_using = true
	player_ref = player
	
	if player_ref:
		player_ref.velocity = Vector2.ZERO
		player_ref.set_physics_process(false)
		player_ref.set_process_input(false)
	
	var hours_awake = 48 - GameManager.sleep
	var sleep_hours = hours_awake / 2.0
	sleep_hours = clamp(sleep_hours, 4.0, 24.0)
	var sleep_minutes = int(sleep_hours * 60.0)
	
	GameManager.sleep = GameManager.max_sleep
	GameManager.sleep_changed.emit()
	
	GameManager.energy = GameManager.max_energy
	GameManager.energy_changed.emit()
	
	GameManager.game_minutes += sleep_minutes
	while GameManager.game_minutes >= 60:
		GameManager.game_minutes -= 60
		GameManager.game_hours += 1
		if GameManager.game_hours >= 24:
			GameManager.game_hours = 0
			GameManager.game_day += 1
	GameManager.time_changed.emit()
	
	GameManager.save_game()
	
	print("[Bed] Loading sleep screen")
	var sleep_screen = load("res://menus/sleep/sleep.tscn")
	if not sleep_screen:
		print("[Bed] Failed to load sleep screen")
		if player_ref:
			player_ref.set_physics_process(true)
			player_ref.set_process_input(true)
			player_ref = null
		is_using = false
		return
	
	var sleep_screen_instance = sleep_screen.instantiate()
	print("[Bed] Sleep screen instantiated")
	get_tree().current_scene.add_child(sleep_screen_instance)
	print("[Bed] Sleep screen added to scene")
	sleep_screen_instance.show_sleep_screen()
	print("[Bed] Sleep screen shown")
	await sleep_screen_instance.tree_exited
	print("[Bed] Sleep screen closed")
	
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref.set_process_input(true)
		player_ref = null
	
	is_using = false

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label and not is_using:
		if GameManager.sleep < 40:
			interact_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
