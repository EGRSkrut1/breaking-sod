extends Control

@onready var continue_button = $ContinueButton

# Initializes main menu
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("[MainMenu] Started")
	
	if not FileAccess.file_exists("user://savegame.json"):
		if continue_button:
			continue_button.disabled = true
			continue_button.modulate = Color(0.5, 0.5, 0.5, 1)
			print("[MainMenu] No save file found, continue button disabled")
	else:
		print("[MainMenu] Save file exists, continue button enabled")

# Starts new game
func _on_new_game_pressed():
	print("[MainMenu] New game pressed")
	GameManager.new_game()
	var result = get_tree().change_scene_to_file("res://maps/forest/forest.tscn")
	print("[MainMenu] Load result: ", result)

# Continues existing game
func _on_continue_pressed():
	print("[MainMenu] Continue pressed")
	if FileAccess.file_exists("user://savegame.json"):
		GameManager.load_game()
	else:
		print("[MainMenu] No save file, starting new game")
		GameManager.new_game()
	var result = get_tree().change_scene_to_file("res://maps/forest/forest.tscn")
	print("[MainMenu] Load result: ", result)

# Quits the game
func _on_quit_pressed():
	print("[MainMenu] Quit pressed")
	get_tree().quit()
