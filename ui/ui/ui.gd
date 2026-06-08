extends CanvasLayer

@onready var top_panel = $TopPanel
@onready var top_buttons = $TopButtons
@onready var left_menu = $LeftMenu
@onready var build_menu = $LeftMenu/BuildMenu
@onready var inventory_menu = $LeftMenu/InventoryMenu
@onready var research_menu = $LeftMenu/ResearchMenu
@onready var water_bar = $WaterBar
@onready var states_panel = $StatesPanel
@onready var pause_menu = $pause_menu
@onready var tooltip = $Tooltip

var active_menu = null

func _ready():
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.card_money_changed.connect(_on_card_money_changed)
	GameManager.seeds_changed.connect(_on_inventory_changed)
	GameManager.inventory_changed.connect(_on_inventory_changed)
	GameManager.energy_changed.connect(_on_energy_changed)
	GameManager.sleep_changed.connect(_on_sleep_changed)
	GameManager.time_changed.connect(_on_time_changed)
	
	if top_buttons:
		var build_btn = top_buttons.get_node_or_null("BuildButton")
		var inventory_btn = top_buttons.get_node_or_null("InventoryButton")
		var research_btn = top_buttons.get_node_or_null("ResearchButton")
		
		if build_btn:
			build_btn.pressed.connect(_on_build_pressed)
			_setup_tooltip_for_button(build_btn, "Open build menu to place buildings and seeds")
		if inventory_btn:
			inventory_btn.pressed.connect(_on_inventory_pressed)
			_setup_tooltip_for_button(inventory_btn, "Open inventory to see your items")
		if research_btn:
			research_btn.pressed.connect(_on_research_pressed)
			_setup_tooltip_for_button(research_btn, "Open research to unlock new items")
	
	update_all()
	
	if left_menu:
		left_menu.visible = false
	
	if pause_menu:
		pause_menu.visible = false
	
	if tooltip:
		tooltip.visible = false

func _setup_tooltip_for_button(button: Button, text: String):
	button.mouse_entered.connect(_on_button_hover.bind(button, text))
	button.mouse_exited.connect(_on_button_hover_end)

func _on_button_hover(button: Button, text: String):
	if tooltip:
		var pos = button.global_position
		tooltip.show_tooltip(text, pos)

func _on_button_hover_end():
	if tooltip:
		tooltip.hide_tooltip()

func show_tooltip_at_position(text: String, pos: Vector2):
	if tooltip:
		tooltip.show_tooltip(text, pos)

func show_permanent_tooltip(text: String, pos: Vector2):
	if tooltip:
		tooltip.show_permanent_tooltip(text, pos)

func hide_tooltip():
	if tooltip:
		tooltip.hide_tooltip()

func show_floating_text(text: String, color: Color, global_pos: Vector2):
	var floating_scene = load("res://ui/ui/components/floating text/floating_text.tscn")
	if floating_scene:
		var floating = floating_scene.instantiate()
		floating.setup(text, color)
		floating.global_position = global_pos
		floating.z_index = 10000
		add_child(floating)
	else:
		print("[UI] floating_text.tscn not found")

func update_all():
	update_money()
	update_card_money()
	update_inventory()
	update_energy()
	update_sleep()
	update_time()
	if water_bar and water_bar.has_method("update_water"):
		water_bar.update_water()

func update_money():
	if top_panel and top_panel.has_method("update_money"):
		top_panel.update_money()

func update_card_money():
	if top_panel and top_panel.has_method("update_card_money"):
		top_panel.update_card_money()

func update_inventory():
	if inventory_menu and inventory_menu.has_method("update_inventory"):
		inventory_menu.update_inventory()
	if build_menu and build_menu.has_method("update_build_buttons"):
		build_menu.update_build_buttons()

func update_energy():
	if states_panel and states_panel.has_method("update_energy"):
		states_panel.update_energy()

func update_sleep():
	if states_panel and states_panel.has_method("update_sleep"):
		states_panel.update_sleep()

func update_time():
	if top_panel and top_panel.has_method("update_time"):
		top_panel.update_time()

func is_any_menu_open() -> bool:
	return active_menu != null

func close_all_menus():
	if left_menu:
		left_menu.visible = false
	if build_menu:
		build_menu.visible = false
	if inventory_menu:
		inventory_menu.visible = false
	if research_menu:
		research_menu.visible = false
	active_menu = null

func close_left_menu():
	if left_menu:
		left_menu.visible = false
	if build_menu:
		build_menu.visible = false
	if inventory_menu:
		inventory_menu.visible = false
	if research_menu:
		research_menu.visible = false
	active_menu = null

func toggle_menu(menu):
	if active_menu == menu:
		close_all_menus()
	else:
		close_all_menus()
		if menu:
			if left_menu:
				left_menu.visible = true
			menu.visible = true
			active_menu = menu
			if menu == build_menu and build_menu.has_method("update_build_buttons"):
				build_menu.update_build_buttons()
			if menu == inventory_menu and inventory_menu.has_method("update_inventory"):
				inventory_menu.update_inventory()

func _on_build_pressed():
	toggle_menu(build_menu)

func _on_inventory_pressed():
	toggle_menu(inventory_menu)

func _on_research_pressed():
	toggle_menu(research_menu)

func _on_money_changed():
	update_money()
	update_card_money()

func _on_card_money_changed():
	update_card_money()

func _on_energy_changed():
	update_energy()

func _on_sleep_changed():
	update_sleep()

func _on_time_changed():
	update_time()

func _on_inventory_changed():
	update_inventory()

func handle_escape():
	if active_menu != null:
		close_all_menus()
		return true
	return false
