extends CharacterBody2D

enum CustomerState { WALKING, INTERACTING, LEAVING }

var state: CustomerState = CustomerState.WALKING
var target_position: Vector2 = Vector2.ZERO
var speed: float = 50.0
var move_timer: float = 0.0
var wait_timer: float = 0.0
var patience: float = 60.0
var cooldown_timer: float = 0.0
var is_on_cooldown: bool = false
var cooldown_duration: float = 720.0

@onready var anim_sprite = $AnimatedSprite2D
@onready var interact_label = $Label
@onready var cooldown_progress = $ProgressBar

func _ready():
	add_to_group("customers")
	
	print("[Customer] Started")
	
	if interact_label:
		interact_label.visible = false
		interact_label.text = "[E] Sell Item"
	
	if cooldown_progress:
		cooldown_progress.visible = false
		cooldown_progress.min_value = 0
		cooldown_progress.max_value = cooldown_duration
		cooldown_progress.value = 0
	
	randomize()
	set_random_target()

func set_random_target():
	var viewport = get_viewport_rect().size
	target_position = Vector2(randf_range(50, viewport.x - 50), randf_range(50, viewport.y - 50))
	move_timer = randf_range(2.0, 5.0)

func _physics_process(delta):
	if is_on_cooldown:
		cooldown_timer += delta
		if cooldown_progress:
			cooldown_progress.visible = true
			cooldown_progress.value = cooldown_timer
		
		if cooldown_timer >= cooldown_duration:
			is_on_cooldown = false
			cooldown_timer = 0.0
			state = CustomerState.WALKING
			if cooldown_progress:
				cooldown_progress.visible = false
		return
	
	match state:
		CustomerState.WALKING:
			walk_to_target(delta)
		CustomerState.INTERACTING:
			wait_timer += delta
			if wait_timer >= patience:
				leave()
		CustomerState.LEAVING:
			leave()

func walk_to_target(delta):
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	update_animation(direction)
	
	move_timer -= delta
	if move_timer <= 0 or global_position.distance_to(target_position) < 20:
		set_random_target()

func update_animation(direction: Vector2):
	if direction.length() == 0:
		play_idle_animation()
		return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_sprite.play("walk side")
			anim_sprite.flip_h = false
		else:
			anim_sprite.play("walk side")
			anim_sprite.flip_h = true
	else:
		if direction.y > 0:
			anim_sprite.play("walk down")
		else:
			anim_sprite.play("walk up")

func play_idle_animation():
	if anim_sprite.sprite_frames.has_animation("idle"):
		anim_sprite.play("idle")
	else:
		anim_sprite.stop()

func interact():
	print("[Customer] Interact called")
	if is_on_cooldown:
		print("[Customer] On cooldown")
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist > 50:
		return
	
	state = CustomerState.INTERACTING
	wait_timer = 0.0
	velocity = Vector2.ZERO
	anim_sprite.stop()
	
	open_customer_ui()

func open_customer_ui():
	print("[Customer] Opening Customer UI")
	
	var customer_ui = get_tree().current_scene.get_node_or_null("CustomerUI")
	if not customer_ui:
		customer_ui = get_node("/root/Main/CustomerUI")
	
	if customer_ui:
		print("[Customer] CustomerUI found")
		customer_ui.visible = true
		customer_ui.set_customer(self)

func leave():
	state = CustomerState.WALKING
	is_on_cooldown = true
	cooldown_timer = 0.0
	set_random_target()
	
	if interact_label:
		interact_label.visible = false

func start_cooldown():
	state = CustomerState.WALKING
	is_on_cooldown = true
	cooldown_timer = 0.0
	set_random_target()
	
	if interact_label:
		interact_label.visible = false

func resume_walking():
	if state == CustomerState.INTERACTING:
		state = CustomerState.WALKING
		wait_timer = 0.0
		set_random_target()
		velocity = Vector2.ZERO

func _on_body_entered(body):
	if body.is_in_group("player") and interact_label and state == CustomerState.WALKING and not is_on_cooldown:
		interact_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and interact_label:
		interact_label.visible = false
