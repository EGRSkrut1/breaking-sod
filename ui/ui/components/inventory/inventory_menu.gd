extends Panel

# Container for inventory items list
@onready var inventory_list = $ItemList

# Default icon for items
var default_icon = preload("res://assets/icon/dollar.png")


# Called when inventory menu is loaded
func _ready():
	update_inventory()


# Updates the inventory display
func update_inventory():
	for child in inventory_list.get_children():
		child.queue_free()
	
	var seed_names = {
		"green": "Green Weed Seeds",
		"purple": "Purple Haze Seeds",
		"white": "White Widow Seeds"
	}
	
	var item_names = {
		"crop": "Crop - Garden bed for planting",
		"well": "Well - Source of water",
		"pc": "PC - Access to seed shop",
		"atm": "ATM - Convert cash to card money",
		"basement": "Basement - Underground expansion",
		"bed": "Bed - Restore energy and sleep",
		"laptop": "Laptop - Access to darknet",
		"graver": "Graver - Process plants into chopped",
		"dryer": "Dryer - Dry chopped plants",
		"wrapper": "Wrapper - Pack dried plants"
	}
	
	var item_descriptions = {
		"green": "Fast growing, low profit. Takes 60 seconds. Requires 1 water.",
		"purple": "Medium growing, medium profit. Takes 90 seconds. Requires 2 water.",
		"white": "Slow growing, high profit. Takes 120 seconds. Requires 3 water.",
		"crop": "Place on empty soil to start planting. Takes 1 slot.",
		"well": "Place near crops. Refills water every 5 seconds.",
		"pc": "Place anywhere. Opens computer UI to buy seeds.",
		"atm": "Place anywhere. Converts cash to card money and vice versa.",
		"basement": "Place once per map. Leads to underground mining area.",
		"bed": "Place indoors. Restores 100 energy and 100 sleep.",
		"laptop": "Place once. Opens darknet market.",
		"graver": "Place near farm. Processes raw plants into chopped.",
		"dryer": "Place near graver. Dries chopped plants.",
		"wrapper": "Place near dryer. Wraps dried plants for premium price."
	}
	
	var grouped_items = {}
	
	# Group seeds by type
	for seed_type in GameManager.seeds:
		if GameManager.unlocked_seeds.get(seed_type, false):
			var count = GameManager.get_seed_count(seed_type)
			if count > 0:
				var name = seed_names.get(seed_type, seed_type)
				var key = "seed_" + seed_type
				grouped_items[key] = {
					"name": name,
					"count": count,
					"is_seed": true,
					"type": seed_type
				}
	
	# Group other inventory items by type
	for item in GameManager.inventory:
		var key = item["type"]
		if grouped_items.has(key):
			grouped_items[key]["count"] += 1
		else:
			var display_name = item_names.get(key, item["name"])
			grouped_items[key] = {
				"name": display_name,
				"count": 1,
				"is_seed": false,
				"type": key
			}
	
	# Show empty message if inventory is empty
	if grouped_items.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Inventory is empty"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inventory_list.add_child(empty_label)
		return
	
	# Display each item group
	for key in grouped_items:
		var item = grouped_items[key]
		var container = CenterContainer.new()
		container.custom_minimum_size = Vector2(300, 40)
		
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var icon_sprite = Sprite2D.new()
		icon_sprite.texture = default_icon
		icon_sprite.scale = Vector2(0.04, 0.04)
		hbox.add_child(icon_sprite)
		
		var label = Label.new()
		label.text = item["name"] + " x" + str(item["count"])
		label.add_theme_font_size_override("font_size", 14)
		hbox.add_child(label)
		
		container.add_child(hbox)
		inventory_list.add_child(container)
		
		# Add tooltip for this item
		var tooltip_text = item_descriptions.get(item["type"], item["name"])
		setup_tooltip_for_container(container, tooltip_text)


# Sets up mouse hover events for tooltip on a container
func setup_tooltip_for_container(container: CenterContainer, text: String):
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		container.mouse_entered.connect(_on_container_hover.bind(container, text, ui))
		container.mouse_exited.connect(_on_container_hover_end.bind(ui))


# Shows tooltip when mouse enters container
func _on_container_hover(container: CenterContainer, text: String, ui: CanvasLayer):
	if ui and ui.has_method("show_tooltip_at_position"):
		var pos = container.global_position
		ui.show_tooltip_at_position(text, pos)


# Hides tooltip when mouse leaves container
func _on_container_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()
