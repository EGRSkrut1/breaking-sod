extends Control

@onready var continue_button = $VBoxContainer/ContinueButton
@onready var save_button = $VBoxContainer/SaveButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var settings = $Settings

func _ready():
	visible = false
	if settings:
		settings.visible = false
	
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if save_button:
		save_button.pressed.connect(_on_save_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	call_deferred("_connect_auto_save")

func _connect_auto_save():
	var auto_save = get_node("/root/AutoSave")
	if auto_save and auto_save.has_method("on_game_paused"):
		visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	var auto_save = get_node("/root/AutoSave")
	if auto_save:
		if visible:
			if auto_save.has_method("on_game_paused"):
				auto_save.on_game_paused()
		else:
			if auto_save.has_method("on_game_resumed"):
				auto_save.on_game_resumed()

func _on_continue_pressed():
	visible = false

func _on_save_pressed():
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("save_all_crops"):
		main_node.save_all_crops()
	if main_node and main_node.has_method("save_water_state"):
		main_node.save_water_state()
	GameManager.save_game()
	print("[PauseMenu] Game manually saved")
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_floating_text"):
		ui.show_floating_text("Game Saved", Color(0, 1, 0), Vector2(400, 300))

func _on_settings_pressed():
	if settings:
		settings.visible = true
		visible = false

func _on_main_menu_pressed():
	GameManager.save_game()
	get_tree().change_scene_to_file("res://menus/main menu/main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("cancel") and visible:
		if settings and settings.visible:
			settings.visible = false
		else:
			visible = false
		get_viewport().set_input_as_handled()
