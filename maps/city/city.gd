extends Node2D

var player = null

func _ready():
	print("[City] Started")
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	if player:
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			camera.limit_left = -100000
			camera.limit_top = -100000
			camera.limit_right = 100000
			camera.limit_bottom = 100000
			print("[City] Camera configured")
		
		player.z_index = 100
	
	var ui = get_node_or_null("UI")
	if ui:
		if ui.has_method("update_all"):
			ui.update_all()
		_reconnect_ui_signals(ui)
		_reconnect_build_menu_signals(ui)
	
	print("[City] Ready")

func _reconnect_ui_signals(ui: CanvasLayer):
	var top_panel = ui.get_node_or_null("TopPanel")
	if top_panel:
		var calendar_button = top_panel.get_node_or_null("calendar")
		var suspicion_bar = top_panel.get_node_or_null("Suspicion")
		if calendar_button:
			if calendar_button.mouse_entered.is_connected(_on_calendar_hover):
				calendar_button.mouse_entered.disconnect(_on_calendar_hover)
			if calendar_button.mouse_exited.is_connected(_on_calendar_hover_end):
				calendar_button.mouse_exited.disconnect(_on_calendar_hover_end)
			calendar_button.mouse_entered.connect(_on_calendar_hover.bind(calendar_button, ui))
			calendar_button.mouse_exited.connect(_on_calendar_hover_end.bind(ui))
		if suspicion_bar:
			if suspicion_bar.mouse_entered.is_connected(_on_suspicion_hover):
				suspicion_bar.mouse_entered.disconnect(_on_suspicion_hover)
			if suspicion_bar.mouse_exited.is_connected(_on_suspicion_hover_end):
				suspicion_bar.mouse_exited.disconnect(_on_suspicion_hover_end)
			suspicion_bar.mouse_entered.connect(_on_suspicion_hover.bind(suspicion_bar, ui))
			suspicion_bar.mouse_exited.connect(_on_suspicion_hover_end.bind(ui))
	
	var states_panel = ui.get_node_or_null("StatesPanel")
	if states_panel:
		var energy_bar = states_panel.get_node_or_null("Energy")
		var sleep_bar = states_panel.get_node_or_null("Sleep")
		if energy_bar:
			if energy_bar.mouse_entered.is_connected(_on_energy_hover):
				energy_bar.mouse_entered.disconnect(_on_energy_hover)
			if energy_bar.mouse_exited.is_connected(_on_energy_hover_end):
				energy_bar.mouse_exited.disconnect(_on_energy_hover_end)
			energy_bar.mouse_entered.connect(_on_energy_hover.bind(energy_bar, ui))
			energy_bar.mouse_exited.connect(_on_energy_hover_end.bind(ui))
		if sleep_bar:
			if sleep_bar.mouse_entered.is_connected(_on_sleep_hover):
				sleep_bar.mouse_entered.disconnect(_on_sleep_hover)
			if sleep_bar.mouse_exited.is_connected(_on_sleep_hover_end):
				sleep_bar.mouse_exited.disconnect(_on_sleep_hover_end)
			sleep_bar.mouse_entered.connect(_on_sleep_hover.bind(sleep_bar, ui))
			sleep_bar.mouse_exited.connect(_on_sleep_hover_end.bind(ui))
	
	var water_bar = ui.get_node_or_null("WaterBar")
	if water_bar:
		var progress_bar = water_bar.get_node_or_null("ProgressBar")
		if progress_bar:
			if progress_bar.mouse_entered.is_connected(_on_water_hover):
				progress_bar.mouse_entered.disconnect(_on_water_hover)
			if progress_bar.mouse_exited.is_connected(_on_water_hover_end):
				progress_bar.mouse_exited.disconnect(_on_water_hover_end)
			progress_bar.mouse_entered.connect(_on_water_hover.bind(progress_bar, ui))
			progress_bar.mouse_exited.connect(_on_water_hover_end.bind(ui))

func _reconnect_build_menu_signals(ui: CanvasLayer):
	var left_menu = ui.get_node_or_null("LeftMenu")
	if not left_menu:
		return
	
	var build_menu = left_menu.get_node_or_null("BuildMenu")
	if build_menu and build_menu.has_method("update_build_buttons"):
		build_menu.update_build_buttons()
		
		var buttons_container = build_menu.get_node_or_null("GridContainer")
		if buttons_container:
			for button in buttons_container.get_children():
				if button is Button and button.has_meta("action"):
					if not button.mouse_entered.is_connected(_on_build_button_hover):
						button.mouse_entered.connect(_on_build_button_hover.bind(button, ui))
					if not button.mouse_exited.is_connected(_on_build_button_hover_end):
						button.mouse_exited.connect(_on_build_button_hover_end.bind(ui))

func _on_build_button_hover(button: Button, ui: CanvasLayer):
	var description = ""
	var build_items = {
		"crop": "Garden bed for planting seeds",
		"well": "Source of water for plants",
		"pc": "Buy seeds using card money",
		"atm": "Transfer between cash and card",
		"basement": "Underground mining area",
		"bed": "Restore energy and sleep",
		"laptop": "Access to darknet market",
		"graver": "Process plants into chopped version (+50 percent value)",
		"dryer": "Dry chopped plants (+100 percent value)",
		"wrapper": "Pack dried plants (+200 percent value)",
		"green": "Fast growing, low profit plant",
		"purple": "Medium growing, medium profit plant",
		"white": "Slow growing, high profit plant"
	}
	
	var action = button.get_meta("action", "")
	if build_items.has(action):
		description = build_items[action]
	
	if description != "" and ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(description, button.global_position)

func _on_build_button_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_calendar_hover(button, ui: CanvasLayer):
	var message = "Day: " + str(GameManager.game_day) + "\n"
	message += "Time: " + str(GameManager.game_hours).pad_zeros(2) + ":" + str(GameManager.game_minutes).pad_zeros(2)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(message, button.global_position)

func _on_calendar_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_suspicion_hover(bar, ui: CanvasLayer):
	var text = "Suspicion: " + str(GameManager.suspicion) + "%"
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, bar.global_position)

func _on_suspicion_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_energy_hover(bar, ui: CanvasLayer):
	var text = "Energy: " + str(GameManager.energy) + "/" + str(GameManager.max_energy)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, bar.global_position)

func _on_energy_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_sleep_hover(bar, ui: CanvasLayer):
	var text = "Sleep: " + str(GameManager.sleep) + "/" + str(GameManager.max_sleep)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, bar.global_position)

func _on_sleep_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_water_hover(bar, ui: CanvasLayer):
	var main_node = get_tree().current_scene
	var current = 0
	var max_water = 0
	if main_node and main_node.has_method("get_current_water") and main_node.has_method("get_max_water"):
		current = main_node.get_current_water()
		max_water = main_node.get_max_water()
	var text = "Water: " + str(current) + "/" + str(max_water)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, bar.global_position)

func _on_water_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func set_selected_build_item(item: String):
	print("[City] Cannot build here")
