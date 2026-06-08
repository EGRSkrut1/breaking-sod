extends BasePage
class_name GrowShopEquipmentPage

@onready var crop_count_label = $Crop/Count/Text/count
@onready var crop_add_button = $Crop/Count/add
@onready var crop_subtract_button = $Crop/Count/subtract
@onready var well_count_label = $Well/Count/Text/count
@onready var well_add_button = $Well/Count/add
@onready var well_subtract_button = $Well/Count/subtract
@onready var graver_count_label = $Graver/Count/Text/count
@onready var graver_add_button = $Graver/Count/add
@onready var graver_subtract_button = $Graver/Count/subtract
@onready var dryer_count_label = $Dryer/Count/Text/count
@onready var dryer_add_button = $Dryer/Count/add
@onready var dryer_subtract_button = $Dryer/Count/subtract
@onready var wrapper_count_label = $Wrapper/Count/Text/count
@onready var wrapper_add_button = $Wrapper/Count/add
@onready var wrapper_subtract_button = $Wrapper/Count/subtract
@onready var laptop_count_label = $Laptop/Count/Text/count
@onready var laptop_add_button = $Laptop/Count/add
@onready var laptop_subtract_button = $Laptop/Count/subtract
@onready var bed_count_label = $Bed/Count/Text/count
@onready var bed_add_button = $Bed/Count/add
@onready var bed_subtract_button = $Bed/Count/subtract
@onready var buy_button = $BuyPanel/Buy
@onready var buy_count_label = $BuyPanel/Count
@onready var graver_panel = $Graver
@onready var dryer_panel = $Dryer
@onready var wrapper_panel = $Wrapper
@onready var laptop_panel = $Laptop
@onready var bed_panel = $Bed

var crop_count: int = 0
var well_count: int = 0
var graver_count: int = 0
var dryer_count: int = 0
var wrapper_count: int = 0
var laptop_count: int = 0
var bed_count: int = 0

func _ready():
	print("[GrowShopEquipmentPage] Ready")
	if crop_add_button:
		crop_add_button.pressed.connect(_on_crop_add)
	if crop_subtract_button:
		crop_subtract_button.pressed.connect(_on_crop_subtract)
	if well_add_button:
		well_add_button.pressed.connect(_on_well_add)
	if well_subtract_button:
		well_subtract_button.pressed.connect(_on_well_subtract)
	if graver_add_button:
		graver_add_button.pressed.connect(_on_graver_add)
	if graver_subtract_button:
		graver_subtract_button.pressed.connect(_on_graver_subtract)
	if dryer_add_button:
		dryer_add_button.pressed.connect(_on_dryer_add)
	if dryer_subtract_button:
		dryer_subtract_button.pressed.connect(_on_dryer_subtract)
	if wrapper_add_button:
		wrapper_add_button.pressed.connect(_on_wrapper_add)
	if wrapper_subtract_button:
		wrapper_subtract_button.pressed.connect(_on_wrapper_subtract)
	if laptop_add_button:
		laptop_add_button.pressed.connect(_on_laptop_add)
	if laptop_subtract_button:
		laptop_subtract_button.pressed.connect(_on_laptop_subtract)
	if bed_add_button:
		bed_add_button.pressed.connect(_on_bed_add)
	if bed_subtract_button:
		bed_subtract_button.pressed.connect(_on_bed_subtract)
	if buy_button:
		buy_button.pressed.connect(_on_buy_pressed)
	
	update_equipment_visibility()

func update_equipment_visibility():
	if graver_panel:
		graver_panel.visible = GameManager.unlocked_equipment.get("graver", false)
	if dryer_panel:
		dryer_panel.visible = GameManager.unlocked_equipment.get("dryer", false)
	if wrapper_panel:
		wrapper_panel.visible = GameManager.unlocked_equipment.get("wrapper", false)
	if laptop_panel:
		laptop_panel.visible = GameManager.unlocked_equipment.get("laptop", false)
	if bed_panel:
		bed_panel.visible = GameManager.unlocked_equipment.get("bed", false)
	print("[GrowShopEquipmentPage] Equipment visibility updated")

func _on_crop_add():
	crop_count += 1
	if crop_count_label:
		crop_count_label.text = str(crop_count)
	update_buy_price()

func _on_crop_subtract():
	if crop_count > 0:
		crop_count -= 1
		if crop_count_label:
			crop_count_label.text = str(crop_count)
	update_buy_price()

func _on_well_add():
	well_count += 1
	if well_count_label:
		well_count_label.text = str(well_count)
	update_buy_price()

func _on_well_subtract():
	if well_count > 0:
		well_count -= 1
		if well_count_label:
			well_count_label.text = str(well_count)
	update_buy_price()

func _on_graver_add():
	graver_count += 1
	if graver_count_label:
		graver_count_label.text = str(graver_count)
	update_buy_price()

func _on_graver_subtract():
	if graver_count > 0:
		graver_count -= 1
		if graver_count_label:
			graver_count_label.text = str(graver_count)
	update_buy_price()

func _on_dryer_add():
	dryer_count += 1
	if dryer_count_label:
		dryer_count_label.text = str(dryer_count)
	update_buy_price()

func _on_dryer_subtract():
	if dryer_count > 0:
		dryer_count -= 1
		if dryer_count_label:
			dryer_count_label.text = str(dryer_count)
	update_buy_price()

func _on_wrapper_add():
	wrapper_count += 1
	if wrapper_count_label:
		wrapper_count_label.text = str(wrapper_count)
	update_buy_price()

func _on_wrapper_subtract():
	if wrapper_count > 0:
		wrapper_count -= 1
		if wrapper_count_label:
			wrapper_count_label.text = str(wrapper_count)
	update_buy_price()

func _on_laptop_add():
	laptop_count += 1
	if laptop_count_label:
		laptop_count_label.text = str(laptop_count)
	update_buy_price()

func _on_laptop_subtract():
	if laptop_count > 0:
		laptop_count -= 1
		if laptop_count_label:
			laptop_count_label.text = str(laptop_count)
	update_buy_price()

func _on_bed_add():
	bed_count += 1
	if bed_count_label:
		bed_count_label.text = str(bed_count)
	update_buy_price()

func _on_bed_subtract():
	if bed_count > 0:
		bed_count -= 1
		if bed_count_label:
			bed_count_label.text = str(bed_count)
	update_buy_price()

func update_buy_price():
	var total = (crop_count * 10) + (well_count * 25) + (graver_count * 100) + (dryer_count * 200) + (wrapper_count * 300) + (laptop_count * 500) + (bed_count * 50)
	if buy_count_label:
		buy_count_label.text = "Total: $" + str(total)
	print("[GrowShopEquipmentPage] Total price: ", total)

func _on_buy_pressed():
	var total = (crop_count * 10) + (well_count * 25) + (graver_count * 100) + (dryer_count * 200) + (wrapper_count * 300) + (laptop_count * 500) + (bed_count * 50)
	
	if GameManager.card_money >= total:
		GameManager.card_money -= total
		
		var ui = get_tree().current_scene.get_node_or_null("UI")
		var player = get_tree().get_first_node_in_group("player")
		var pos = player.global_position if player else Vector2.ZERO
		
		if crop_count > 0:
			for i in range(crop_count):
				GameManager.add_inventory_item({"type": "crop", "name": "Crop", "price": 10})
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(crop_count) + " Crop", Color(0, 1, 0, 1), pos)
			crop_count = 0
			if crop_count_label:
				crop_count_label.text = "0"
		if well_count > 0:
			for i in range(well_count):
				GameManager.add_inventory_item({"type": "well", "name": "Well", "price": 25})
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(well_count) + " Well", Color(0, 1, 0, 1), pos)
			well_count = 0
			if well_count_label:
				well_count_label.text = "0"
		if graver_count > 0 and GameManager.unlocked_equipment.get("graver", false):
			for i in range(graver_count):
				GameManager.add_inventory_item({"type": "graver", "name": "Graver", "price": 100})
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(graver_count) + " Graver", Color(0, 1, 0, 1), pos)
			graver_count = 0
			if graver_count_label:
				graver_count_label.text = "0"
		if dryer_count > 0 and GameManager.unlocked_equipment.get("dryer", false):
			for i in range(dryer_count):
				GameManager.add_inventory_item({"type": "dryer", "name": "Dryer", "price": 200})
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(dryer_count) + " Dryer", Color(0, 1, 0, 1), pos)
			dryer_count = 0
			if dryer_count_label:
				dryer_count_label.text = "0"
		if wrapper_count > 0 and GameManager.unlocked_equipment.get("wrapper", false):
			for i in range(wrapper_count):
				GameManager.add_inventory_item({"type": "wrapper", "name": "Wrapper", "price": 300})
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(wrapper_count) + " Wrapper", Color(0, 1, 0, 1), pos)
			wrapper_count = 0
			if wrapper_count_label:
				wrapper_count_label.text = "0"
		if laptop_count > 0 and GameManager.unlocked_equipment.get("laptop", false):
			for i in range(laptop_count):
				GameManager.add_inventory_item({"type": "laptop", "name": "Laptop", "price": 500})
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(laptop_count) + " Laptop", Color(0, 1, 0, 1), pos)
			laptop_count = 0
			if laptop_count_label:
				laptop_count_label.text = "0"
		if bed_count > 0 and GameManager.unlocked_equipment.get("bed", false):
			for i in range(bed_count):
				GameManager.add_inventory_item({"type": "bed", "name": "Bed", "price": 50})
			if ui and ui.has_method("show_floating_text"):
				ui.show_floating_text("+ " + str(bed_count) + " Bed", Color(0, 1, 0, 1), pos)
			bed_count = 0
			if bed_count_label:
				bed_count_label.text = "0"
		
		update_buy_price()
		update_money()
		
		if ui and ui.has_method("show_floating_text"):
			ui.show_floating_text("-$" + str(total), Color(1, 0.5, 0, 1), pos)
		
		print("[GrowShopEquipmentPage] Purchase successful")
	else:
		print("[GrowShopEquipmentPage] Not enough card money")

func update_money():
	var growshop_page = get_parent().get_parent()
	if growshop_page and growshop_page.has_method("update_money"):
		growshop_page.update_money()

func refresh():
	update_equipment_visibility()
	update_buy_price()
