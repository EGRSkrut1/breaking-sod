extends BasePage
class_name GrowShopPage

@onready var plants_button = $TopPanel/Plants
@onready var equipment_button = $TopPanel/Equipment
@onready var plants_page = $PlantsPage
@onready var equipment_page = $EquipmentPage
@onready var money_label = $TopPanel/Money

var current_subpage = null
var _updating_money = false

func _ready():
	print("[GrowShopPage] Ready")
	if plants_button:
		plants_button.pressed.connect(_on_plants_pressed)
	if equipment_button:
		equipment_button.pressed.connect(_on_equipment_pressed)
	
	hide_subpages()
	show_plants_page()

func hide_subpages():
	if plants_page:
		plants_page.visible = false
	if equipment_page:
		equipment_page.visible = false

func show_plants_page():
	hide_subpages()
	if plants_page:
		plants_page.visible = true
		current_subpage = "plants"
	set_button_active(plants_button, true)
	set_button_active(equipment_button, false)
	if plants_page.has_method("refresh"):
		plants_page.refresh()
	print("[GrowShopPage] Showing plants page")

func show_equipment_page():
	hide_subpages()
	if equipment_page:
		equipment_page.visible = true
		current_subpage = "equipment"
	set_button_active(plants_button, false)
	set_button_active(equipment_button, true)
	if equipment_page.has_method("refresh"):
		equipment_page.refresh()
	print("[GrowShopPage] Showing equipment page")

func set_button_active(button, is_active: bool):
	if button:
		if is_active:
			button.add_theme_color_override("font_color", Color(1, 1, 0))
		else:
			button.add_theme_color_override("font_color", Color(1, 1, 1))

func _on_plants_pressed():
	show_plants_page()

func _on_equipment_pressed():
	show_equipment_page()

func update_money():
	if _updating_money:
		return
	_updating_money = true
	
	if money_label:
		money_label.text = "Card: $" + str(GameManager.card_money)
	
	if current_subpage == "plants" and plants_page and plants_page.has_method("update_money"):
		plants_page.update_money()
	elif current_subpage == "equipment" and equipment_page and equipment_page.has_method("update_money"):
		equipment_page.update_money()
	
	_updating_money = false

func set_shop_data(shop_data: Dictionary):
	if plants_page and plants_page.has_method("set_shop_data"):
		plants_page.set_shop_data(shop_data)

func refresh():
	update_money()
	if current_subpage == "plants" and plants_page and plants_page.has_method("refresh"):
		plants_page.refresh()
	elif current_subpage == "equipment" and equipment_page and plants_page.has_method("refresh"):
		equipment_page.refresh()
