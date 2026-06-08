extends Panel

# Container for build option buttons
@onready var buttons_container = $GridContainer

# Default icon for build items
var default_icon = preload("res://assets/icon/dollar.png")

# List of current build buttons
var build_buttons: Array = []

# Reference to UI for tooltips
var ui_ref = null

# Called when build menu is loaded
func _ready():
	ui_ref = get_tree().current_scene.get_node_or_null("UI")
	update_build_buttons()

# Creates and displays all build options
func update_build_buttons():
	for child in buttons_container.get_children():
		child.queue_free()
	
	build_buttons.clear()
	
	var build_items = [
		{"action": "crop", "name": "Crop", "icon": default_icon, "unlocked": true, "inventory_check": "crop", "seed_check": null, "description": "Garden bed for planting seeds"},
		{"action": "well", "name": "Well", "icon": default_icon, "unlocked": true, "inventory_check": "well", "seed_check": null, "description": "Source of water for plants"},
		{"action": "pc", "name": "PC", "icon": default_icon, "unlocked": true, "inventory_check": "pc", "seed_check": null, "description": "Buy seeds using card money"},
		{"action": "atm", "name": "ATM", "icon": default_icon, "unlocked": true, "inventory_check": "atm", "seed_check": null, "description": "Transfer between cash and card"},
		{"action": "basement", "name": "Basement", "icon": default_icon, "unlocked": true, "inventory_check": "basement", "seed_check": null, "description": "Underground mining area"},
		{"action": "bed", "name": "Bed", "icon": default_icon, "unlocked": true, "inventory_check": "bed", "seed_check": null, "description": "Restore energy and sleep"},
		{"action": "laptop", "name": "Laptop", "icon": default_icon, "unlocked": true, "inventory_check": "laptop", "seed_check": null, "one_time": false, "description": "Access to darknet market"},
		{"action": "graver", "name": "Graver", "icon": default_icon, "unlocked": GameManager.unlocked_equipment.get("graver", false), "inventory_check": "graver", "seed_check": null, "description": "Process plants into chopped version (+50 percent value)"},
		{"action": "dryer", "name": "Dryer", "icon": default_icon, "unlocked": GameManager.unlocked_equipment.get("dryer", false), "inventory_check": "dryer", "seed_check": null, "description": "Dry chopped plants (+100 percent value)"},
		{"action": "wrapper", "name": "Wrapper", "icon": default_icon, "unlocked": GameManager.unlocked_equipment.get("wrapper", false), "inventory_check": "wrapper", "seed_check": null, "description": "Pack dried plants (+200 percent value)"},
		{"action": "green", "name": "Green Weed", "icon": default_icon, "unlocked": true, "inventory_check": null, "seed_check": "green", "description": "Fast growing, low profit plant"},
		{"action": "purple", "name": "Purple Haze", "icon": default_icon, "unlocked": GameManager.unlocked_seeds.get("purple", false), "inventory_check": null, "seed_check": "purple", "description": "Medium growing, medium profit plant"},
		{"action": "white", "name": "White Widow", "icon": default_icon, "unlocked": GameManager.unlocked_seeds.get("white", false), "inventory_check": null, "seed_check": "white", "description": "Slow growing, high profit plant"}
	]
	
	var has_laptop = GameManager.has_inventory_item("laptop")
	var has_any_item = false
	
	for item in build_items:
		if not item["unlocked"]:
			continue
		
		if item.get("inventory_check") and not GameManager.has_inventory_item(item["inventory_check"]):
			continue
		
		if item.get("seed_check") and GameManager.get_seed_count(item["seed_check"]) == 0:
			continue
		
		if item.get("one_time", false) and has_laptop:
			continue
		
		has_any_item = true
		
		var button = Button.new()
		button.set_meta("action", item["action"])
		button.custom_minimum_size = Vector2(100, 90)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var icon_sprite = Sprite2D.new()
		icon_sprite.texture = item["icon"]
		icon_sprite.scale = Vector2(0.05, 0.05)
		icon_sprite.position = Vector2(50, 25)
		vbox.add_child(icon_sprite)
		
		var label = Label.new()
		label.text = item["name"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.position = Vector2(0, 60)
		vbox.add_child(label)
		
		var count_label = Label.new()
		count_label.position = Vector2(80, 5)
		count_label.add_theme_font_size_override("font_size", 10)
		
		if item.get("inventory_check"):
			var count = get_inventory_count(item["inventory_check"])
			if count > 0:
				count_label.text = "x" + str(count)
		elif item.get("seed_check"):
			var count = GameManager.get_seed_count(item["seed_check"])
			if count > 0:
				count_label.text = "x" + str(count)
		
		vbox.add_child(count_label)
		
		button.add_child(vbox)
		button.pressed.connect(_on_build_item_pressed.bind(item["action"]))
		
		button.mouse_entered.connect(_on_button_hover.bind(button, item["description"]))
		button.mouse_exited.connect(_on_button_hover_end)
		
		buttons_container.add_child(button)
		build_buttons.append(button)
	
	if not has_any_item:
		var empty_label = Label.new()
		empty_label.text = "Nothing available to build"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		buttons_container.add_child(empty_label)

# Counts items of given type in inventory
func get_inventory_count(item_type: String) -> int:
	var count = 0
	for item in GameManager.inventory:
		if item["type"] == item_type:
			count += 1
	return count

# Called when a build button is pressed
func _on_build_item_pressed(action: String):
	var forest = get_tree().current_scene
	if forest and forest.has_method("set_selected_build_item"):
		forest.set_selected_build_item(action)
	else:
		var main = get_tree().root.get_node_or_null("Main")
		if main and main.has_method("set_selected_build_item"):
			main.set_selected_build_item(action)
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("close_left_menu"):
		ui.close_left_menu()

func _on_button_hover(button: Button, text: String):
	if ui_ref and ui_ref.has_method("show_tooltip_at_position"):
		ui_ref.show_tooltip_at_position(text, button.global_position)

func _on_button_hover_end():
	if ui_ref and ui_ref.has_method("hide_tooltip"):
		ui_ref.hide_tooltip()
