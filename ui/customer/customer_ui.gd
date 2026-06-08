extends CanvasLayer

var current_customer = null
var offered_item = null
var current_quantity: int = 1
var max_quantity: int = 0
var original_price_per_unit: int = 0
var original_total_price: int = 0
var current_price_per_unit: int = 0
var current_total_price: int = 0
var irritation: float = 0.0

@onready var item_list = $Panel/ScrollContainer/ItemList
@onready var offer_label = $Count/OfferLabel
@onready var price_label = $Count/PriceLabel
@onready var quantity_label = $Count/Text/count
@onready var add_button = $Count/add
@onready var subtract_button = $Count/subtract
@onready var sell_button = $SellButton
@onready var cancel_button = $CancelButton
@onready var irritability_bar = $irritability/ProgressBar
@onready var irritability_add = $irritability/add
@onready var irritability_subtract = $irritability/subtract

var check_distance_timer: float = 0.0

func _ready():
	visible = false
	
	if sell_button:
		sell_button.pressed.connect(_on_sell_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	if add_button:
		add_button.pressed.connect(_on_add_pressed)
	if subtract_button:
		subtract_button.pressed.connect(_on_subtract_pressed)
	if irritability_add:
		irritability_add.pressed.connect(_on_irritability_add)
	if irritability_subtract:
		irritability_subtract.pressed.connect(_on_irritability_subtract)
	
	if irritability_bar:
		irritability_bar.visible = true
		irritability_bar.min_value = 0
		irritability_bar.max_value = 100
		irritability_bar.value = 0
	
	update_item_list()

func _process(delta):
	if visible and current_customer:
		check_distance_timer += delta
		if check_distance_timer >= 0.5:
			check_distance_timer = 0.0
			
			var player = get_tree().get_first_node_in_group("player")
			if player and current_customer:
				var dist = player.global_position.distance_to(current_customer.global_position)
				var dist_cells = dist / 16.0
				
				if dist_cells > 3.0:
					print("[CustomerUI] Player moved too far, closing")
					_on_cancel_pressed()

func set_customer(customer):
	current_customer = customer
	update_item_list()

func update_item_list():
	if not item_list:
		return
	
	for child in item_list.get_children():
		child.queue_free()
	
	var sellable_items = [
		"green", "purple", "white",
		"green_lvl1", "purple_lvl1", "white_lvl1",
		"green_lvl2", "purple_lvl2", "white_lvl2",
		"green_lvl3", "purple_lvl3", "white_lvl3",
		"tin_can", "old_coin", "crystal"
	]
	
	var grouped_items = {}
	for item in GameManager.inventory:
		if item["type"] not in sellable_items:
			continue
		
		var key = item["type"]
		if grouped_items.has(key):
			grouped_items[key]["count"] += 1
		else:
			grouped_items[key] = {
				"type": item["type"],
				"name": item["name"],
				"price": item["price"],
				"count": 1
			}
	
	for key in grouped_items:
		var item = grouped_items[key]
		var button = Button.new()
		button.text = item["name"] + " x" + str(item["count"]) + " ($" + str(item["price"]) + ")"
		button.set_meta("item_type", item["type"])
		button.set_meta("item_name", item["name"])
		button.set_meta("item_price", item["price"])
		button.set_meta("item_count", item["count"])
		button.pressed.connect(_on_item_selected.bind(item))
		item_list.add_child(button)

func _on_item_selected(item: Dictionary):
	offered_item = item
	max_quantity = min(5, item["count"])
	current_quantity = 1
	original_price_per_unit = item["price"]
	current_price_per_unit = original_price_per_unit
	original_total_price = original_price_per_unit * current_quantity
	current_total_price = current_price_per_unit * current_quantity
	irritation = 0.0
	
	if quantity_label:
		quantity_label.text = str(current_quantity)
	if offer_label:
		offer_label.text = "Offer: " + item["name"]
	if price_label:
		price_label.text = "$" + str(current_total_price) + " ($" + str(current_price_per_unit) + "/ea)"
	
	update_irritation_bar()

func _on_add_pressed():
	if not offered_item:
		return
	if current_quantity < max_quantity:
		current_quantity += 1
		quantity_label.text = str(current_quantity)
		original_total_price = original_price_per_unit * current_quantity
		current_total_price = current_price_per_unit * current_quantity
		if price_label:
			price_label.text = "$" + str(current_total_price) + " ($" + str(current_price_per_unit) + "/ea)"
		update_irritation_bar()

func _on_subtract_pressed():
	if not offered_item:
		return
	if current_quantity > 1:
		current_quantity -= 1
		quantity_label.text = str(current_quantity)
		original_total_price = original_price_per_unit * current_quantity
		current_total_price = current_price_per_unit * current_quantity
		if price_label:
			price_label.text = "$" + str(current_total_price) + " ($" + str(current_price_per_unit) + "/ea)"
		update_irritation_bar()

func _on_irritability_add():
	if not offered_item:
		return
	current_price_per_unit += 1
	current_total_price = current_price_per_unit * current_quantity
	if price_label:
		price_label.text = "$" + str(current_total_price) + " ($" + str(current_price_per_unit) + "/ea)"
	update_irritation_bar()

func _on_irritability_subtract():
	if not offered_item:
		return
	if current_price_per_unit > 1:
		current_price_per_unit -= 1
		current_total_price = current_price_per_unit * current_quantity
		if price_label:
			price_label.text = "$" + str(current_total_price) + " ($" + str(current_price_per_unit) + "/ea)"
		update_irritation_bar()

func update_irritation_bar():
	if not offered_item:
		return
	
	var ratio = float(current_total_price) / float(original_total_price)
	
	if ratio <= 0.8:
		irritation = 10.0
	elif ratio <= 1.0:
		irritation = 30.0
	elif ratio <= 1.2:
		irritation = 50.0
	elif ratio <= 1.5:
		irritation = 70.0
	else:
		irritation = 90.0
	
	print("[CustomerUI] Ratio: ", ratio, " Original: ", original_total_price, " Current: ", current_total_price, " Irritation: ", irritation)
	
	if irritability_bar:
		irritability_bar.value = irritation
		
		var bar_color: Color
		if irritation < 30:
			bar_color = Color(0.2, 0.8, 0.2, 1)
		elif irritation < 60:
			bar_color = Color(0.8, 0.8, 0.2, 1)
		else:
			bar_color = Color(0.8, 0.2, 0.2, 1)
		
		var style = StyleBoxFlat.new()
		style.bg_color = bar_color
		irritability_bar.add_theme_stylebox_override("fill", style)

func _on_sell_pressed():
	if not offered_item:
		print("[CustomerUI] No item selected")
		return
	
	var chance = 100.0 - irritation
	var random_chance = randf() * 100
	
	print("[CustomerUI] Selling: ", offered_item["name"], " x", current_quantity)
	print("[CustomerUI] Price per unit: $", current_price_per_unit, " Total: $", current_total_price)
	print("[CustomerUI] Original total: $", original_total_price, " Irritation: ", irritation, "%, Chance: ", chance, "%")
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	
	if random_chance < chance:
		GameManager.add_money(current_total_price)
		for i in range(current_quantity):
			GameManager.remove_inventory_item(offered_item["type"])
		GameManager.add_suspicion(irritation / 10)
		
		if ui and ui.has_method("show_floating_text") and current_customer:
			ui.show_floating_text("SOLD! +$" + str(current_total_price), Color(0, 1, 0), current_customer.global_position)
		print("[CustomerUI] Sale successful!")
	else:
		if ui and ui.has_method("show_floating_text") and current_customer:
			ui.show_floating_text("REFUSED", Color(1, 0, 0), current_customer.global_position)
		print("[CustomerUI] Sale refused!")
	
	if current_customer and current_customer.has_method("start_cooldown"):
		current_customer.start_cooldown()
	
	offered_item = null
	current_quantity = 1
	max_quantity = 0
	original_price_per_unit = 0
	current_price_per_unit = 0
	original_total_price = 0
	current_total_price = 0
	update_item_list()
	
	if offer_label:
		offer_label.text = "Select an item"
	if price_label:
		price_label.text = ""
	if quantity_label:
		quantity_label.text = "1"
	
	if current_customer and current_customer.has_method("resume_walking"):
		current_customer.resume_walking()
	
	visible = false

func _on_cancel_pressed():
	visible = false
	if current_customer and current_customer.has_method("resume_walking"):
		current_customer.resume_walking()
	current_customer = null
	offered_item = null

func _input(event):
	if event.is_action_pressed("cancel") and visible:
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()
