extends BasePage
class_name GrowShopPlantsPage

@onready var green_count_label = $Green/Count/Text/count
@onready var green_add_button = $Green/Count/add
@onready var green_subtract_button = $Green/Count/subtract
@onready var purple_count_label = $Purple/Count/Text/count
@onready var purple_add_button = $Purple/Count/add
@onready var purple_subtract_button = $Purple/Count/subtract
@onready var white_count_label = $White/Count/Text/count
@onready var white_add_button = $White/Count/add
@onready var white_subtract_button = $White/Count/subtract
@onready var buy_button = $BuyPanel/Buy
@onready var buy_count_label = $BuyPanel/Count
@onready var purple_panel = $Purple
@onready var white_panel = $White

var green_count: int = 0
var purple_count: int = 0
var white_count: int = 0
var current_shop_data: Dictionary = {}

func _ready():
	print("[GrowShopPlantsPage] Ready")
	if green_add_button:
		green_add_button.pressed.connect(_on_green_add)
	if green_subtract_button:
		green_subtract_button.pressed.connect(_on_green_subtract)
	if purple_add_button:
		purple_add_button.pressed.connect(_on_purple_add)
	if purple_subtract_button:
		purple_subtract_button.pressed.connect(_on_purple_subtract)
	if white_add_button:
		white_add_button.pressed.connect(_on_white_add)
	if white_subtract_button:
		white_subtract_button.pressed.connect(_on_white_subtract)
	if buy_button:
		buy_button.pressed.connect(_on_buy_pressed)
	
	update_plant_visibility()

func update_plant_visibility():
	if purple_panel:
		purple_panel.visible = GameManager.unlocked_seeds.get("purple", false)
	if white_panel:
		white_panel.visible = GameManager.unlocked_seeds.get("white", false)
	print("[GrowShopPlantsPage] Plant visibility updated")

func _on_green_add():
	green_count += 1
	if green_count_label:
		green_count_label.text = str(green_count)
	update_buy_price()

func _on_green_subtract():
	if green_count > 0:
		green_count -= 1
		if green_count_label:
			green_count_label.text = str(green_count)
	update_buy_price()

func _on_purple_add():
	purple_count += 1
	if purple_count_label:
		purple_count_label.text = str(purple_count)
	update_buy_price()

func _on_purple_subtract():
	if purple_count > 0:
		purple_count -= 1
		if purple_count_label:
			purple_count_label.text = str(purple_count)
	update_buy_price()

func _on_white_add():
	white_count += 1
	if white_count_label:
		white_count_label.text = str(white_count)
	update_buy_price()

func _on_white_subtract():
	if white_count > 0:
		white_count -= 1
		if white_count_label:
			white_count_label.text = str(white_count)
	update_buy_price()

func update_buy_price():
	var total = (green_count * 10) + (purple_count * 25) + (white_count * 50)
	if buy_count_label:
		buy_count_label.text = "Total: $" + str(total)
	print("[GrowShopPlantsPage] Total price: ", total)

func _on_buy_pressed():
	var total = (green_count * 10) + (purple_count * 25) + (white_count * 50)
	
	if GameManager.card_money >= total:
		GameManager.card_money -= total
		
		var ui = get_tree().current_scene.get_node_or_null("UI")
		var player = get_tree().get_first_node_in_group("player")
		var pos = player.global_position if player else Vector2.ZERO
		
		if green_count > 0:
			GameManager.add_seeds("green", green_count)
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(green_count) + " Green Seeds", Color(0, 1, 0, 1), pos)
			green_count = 0
			if green_count_label:
				green_count_label.text = "0"
		if purple_count > 0 and GameManager.unlocked_seeds.get("purple", false):
			GameManager.add_seeds("purple", purple_count)
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(purple_count) + " Purple Seeds", Color(0, 1, 0, 1), pos)
			purple_count = 0
			if purple_count_label:
				purple_count_label.text = "0"
		if white_count > 0 and GameManager.unlocked_seeds.get("white", false):
			GameManager.add_seeds("white", white_count)
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(white_count) + " White Seeds", Color(0, 1, 0, 1), pos)
			white_count = 0
			if white_count_label:
				white_count_label.text = "0"
		
		update_buy_price()
		update_money()
		
		if ui and ui.has_method("show_floating_text"):
			ui.show_floating_text("-$" + str(total), Color(1, 0.5, 0, 1), pos)
		
		print("[GrowShopPlantsPage] Purchase successful")
	else:
		print("[GrowShopPlantsPage] Not enough card money")

func update_money():
	var growshop_page = get_parent()
	if growshop_page and growshop_page.has_method("update_money"):
		growshop_page.update_money()

func set_shop_data(shop_data: Dictionary):
	current_shop_data = shop_data
	update_plant_visibility()

func refresh():
	update_plant_visibility()
	update_buy_price()
