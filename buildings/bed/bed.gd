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
	
	print("[Bed] Started")
	
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
	print("[Bed] Interact called")
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		return
	
	if is_using:
		return
	
	start_sleeping(player)

func start_sleeping(player):
	print("[Bed] Start sleeping")
	is_using = true
	player_ref = player
	
	if progress_bar:
		progress_bar.visible = true
		progress_bar.value = 0
	
	if player_ref:
		player_ref.velocity = Vector2.ZERO
		player_ref.set_physics_process(false)
	
	var old_energy = GameManager.energy
	var old_sleep = GameManager.sleep
	
	var hours_awake = 48.0 - (float(GameManager.sleep) / float(GameManager.max_sleep) * 48.0)
	var sleep_hours = clamp(hours_awake * 0.33, 4.0, 16.0)
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
	
	var energy_gained = GameManager.energy - old_energy
	var sleep_gained = GameManager.sleep - old_sleep
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		if energy_gained > 0:
			ui.show_floating_text("+" + str(energy_gained), Color(1, 1, 0, 1), global_position + Vector2(-20, -30))
		if sleep_gained > 0:
			ui.show_floating_text("+" + str(sleep_gained), Color(0.8, 0.2, 0.8, 1), global_position + Vector2(20, -30))
	
	var timer = 0.0
	var animation_duration = 1.0
	while timer < animation_duration:
		await get_tree().create_timer(0.05).timeout
		timer += 0.05
		if progress_bar:
			progress_bar.value = (timer / animation_duration) * 100
	
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref = null
	
	is_using = false
	
	if progress_bar:
		progress_bar.visible = false
	
	print("[Bed] Sleep complete")

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label and not is_using:
		interact_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
