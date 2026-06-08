extends TextureButton

@onready var anim_sprite = $AnimatedSprite2D
@export var action: String = ""

# Initializes animated button
func _ready():
	custom_minimum_size = Vector2(192, 48)
	anim_sprite.scale = Vector2(3, 3)
	anim_sprite.position = Vector2(0, 0)
	anim_sprite.offset = Vector2(32, 8)
	pressed.connect(_on_pressed)
	print("[AnimatedButton] Ready, action: ", action)

# Handles button press with animation
func _on_pressed():
	anim_sprite.speed_scale = 8.0
	anim_sprite.play("click")
	await anim_sprite.animation_finished
	anim_sprite.speed_scale = 1.0
	anim_sprite.frame = 0
	
	print("[AnimatedButton] Pressed: ", action)
	
	match action:
		"quit":
			print("[AnimatedButton] Quitting game")
			get_tree().quit()
		"new_game":
			print("[AnimatedButton] Starting new game")
			GameManager.new_game()
			var result = get_tree().change_scene_to_file("res://maps/forest/forest.tscn")
			print("[AnimatedButton] Load result: ", result)
		"continue":
			print("[AnimatedButton] Continuing game")
			GameManager.load_game()
			var result = get_tree().change_scene_to_file("res://maps/forest/forest.tscn")
			print("[AnimatedButton] Load result: ", result)
		"settings":
			print("[AnimatedButton] Opening settings")
			var result = get_tree().change_scene_to_file("res://menus/settings/settings.tscn")
			print("[AnimatedButton] Load result: ", result)
