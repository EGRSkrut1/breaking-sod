extends Node
class_name PlayerMovement

var player: CharacterBody2D = null
var speed: float = 200.0
var last_direction: String = "down"

@onready var anim = $"../AnimatedSprite2D"

# Sets up movement component with player reference
func setup(player_node: CharacterBody2D, move_speed: float):
	player = player_node
	speed = move_speed
	print("[PlayerMovement] Setup complete")

# Processes player movement every frame
func process_movement(delta):
	var input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		player.velocity = input_dir * speed
		player.move_and_slide()
		update_animation(input_dir)
	else:
		player.velocity = Vector2.ZERO
		play_idle_animation()

# Updates sprite animation based on movement direction
func update_animation(input_dir: Vector2):
	if abs(input_dir.y) > abs(input_dir.x):
		if input_dir.y > 0:
			anim.play("walk down")
			last_direction = "down"
		else:
			anim.play("walk up")
			last_direction = "up"
	else:
		if input_dir.x > 0:
			anim.play("walk side")
			last_direction = "right"
			anim.flip_h = false
		else:
			anim.play("walk side")
			last_direction = "left"
			anim.flip_h = true

# Plays idle animation based on last movement direction
func play_idle_animation():
	match last_direction:
		"down":
			anim.play("idle down")
		"up":
			anim.play("idle up")
		_:
			anim.play("idle side")
