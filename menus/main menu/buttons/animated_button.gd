extends TextureButton

@onready var anim_sprite = $AnimatedSprite2D
@export var action: String = ""

func _ready():
	custom_minimum_size = Vector2(192, 48)
	anim_sprite.scale = Vector2(3, 3)
	anim_sprite.position = Vector2(0, 0)
	anim_sprite.offset = Vector2(32, 8)
	pressed.connect(_on_pressed)
	print("[AnimatedButton] Ready, action: ", action)

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
			get_tree().change_scene_to_file("res://maps/forest/forest.tscn")
		"continue":
			print("[AnimatedButton] Continuing game")
			GameManager.load_game()
			get_tree().change_scene_to_file("res://maps/forest/forest.tscn")
		"settings":
			print("[AnimatedButton] Opening settings")
			var main = get_tree().current_scene
			var settings = main.get_node_or_null("Settings")
			if settings:
				settings.visible = true
