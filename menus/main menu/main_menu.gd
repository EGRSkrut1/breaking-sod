extends Control

@onready var continue_button = $ContinueButton
@onready var settings = $Settings

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("[MainMenu] Started")
	
	if settings:
		settings.visible = false
	
	if not FileAccess.file_exists("user://savegame.json"):
		if continue_button:
			continue_button.disabled = true
			continue_button.modulate = Color(0.5, 0.5, 0.5, 1)
			print("[MainMenu] No save file found, continue button disabled")
	else:
		print("[MainMenu] Save file exists, continue button enabled")

func _on_new_game_pressed():
	print("[MainMenu] New game pressed")
	GameManager.new_game()
	var loading = load("res://menus/loading/loading.tscn").instantiate()
	add_child(loading)
	loading.start_load("res://maps/forest/forest.tscn")
	await loading.loading_complete
	loading.queue_free()

func _on_continue_pressed():
	print("[MainMenu] Continue pressed")
	if FileAccess.file_exists("user://savegame.json"):
		GameManager.load_game()
	else:
		print("[MainMenu] No save file, starting new game")
		GameManager.new_game()
	var loading = load("res://menus/loading/loading.tscn").instantiate()
	add_child(loading)
	loading.start_load("res://maps/forest/forest.tscn")
	await loading.loading_complete
	loading.queue_free()

func _on_quit_pressed():
	print("[MainMenu] Quit pressed")
	get_tree().quit()

func _on_settings_pressed():
	if settings:
		settings.visible = true

func _input(event):
	if event.is_action_pressed("cancel"):
		if settings and settings.visible:
			settings.visible = false
			get_viewport().set_input_as_handled()
