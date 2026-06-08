extends Area2D

var is_active: bool = true
var refill_cooldown: float = 0.0
var max_cooldown: float = 5.0
var cell_pos: Vector2 = Vector2.ZERO
var is_refilling: bool = false
var refill_timer: float = 0.0
var refill_duration: float = 3.0
var player_refilling = null

@onready var anim_sprite = $AnimatedSprite2D
@onready var progress_bar = $ProgressBar
@onready var interact_label = $Label

func _ready():
	add_to_group("buildings")
	print("[Well] Started")
	
	if anim_sprite and anim_sprite.sprite_frames:
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
	
	if progress_bar:
		progress_bar.visible = false
		progress_bar.max_value = refill_duration
		progress_bar.value = 0
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Get Water"

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func get_save_data() -> Dictionary:
	return {
		"type": "well",
		"position_x": int(cell_pos.x),
		"position_y": int(cell_pos.y)
	}

func _process(delta):
	if is_refilling and player_refilling:
		refill_timer += delta
		if progress_bar:
			progress_bar.value = refill_timer
		if refill_timer >= refill_duration:
			finish_refill()

func interact():
	if is_refilling:
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var player = players[0]
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		return
	if not is_active:
		return
	start_refill(player)

func start_refill(player):
	is_refilling = true
	player_refilling = player
	refill_timer = 0.0
	if progress_bar:
		progress_bar.visible = true
		progress_bar.value = 0
	if interact_label:
		interact_label.visible = false
	if player_refilling:
		player_refilling.velocity = Vector2.ZERO
		player_refilling.set_physics_process(false)
	print("[Well] Started refilling")

func finish_refill():
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("refill_water"):
		main_node.refill_water()
	is_refilling = false
	if player_refilling:
		player_refilling.set_physics_process(true)
		player_refilling = null
	is_active = false
	refill_cooldown = max_cooldown
	if progress_bar:
		progress_bar.visible = false
	await get_tree().create_timer(max_cooldown).timeout
	is_active = true
	if interact_label:
		interact_label.visible = true
	print("[Well] Finished refilling")

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label and is_active and not is_refilling:
		interact_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
