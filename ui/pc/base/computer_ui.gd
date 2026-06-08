extends CanvasLayer

# Reference to desktop page (main screen)
@onready var page_desktop = $PageDesktop

# Reference to darknet page
@onready var page_net = $PageNet

# Reference to close button
@onready var close_button = $CloseButton

# Reference to darknet entry button
@onready var iconet = $PageDesktop/Iconet

# Navigation buttons for darknet pages
@onready var search_button = $PageNet/TopPanel/Search
@onready var exchange_button = $PageNet/TopPanel/Exchange
@onready var growshop_button = $PageNet/TopPanel/GrowShop
@onready var bank_button = $PageNet/TopPanel/Bank

# Content pages for darknet
@onready var search_page = $PageNet/Search
@onready var exchange_page = $PageNet/Exchange
@onready var growshop_page = $PageNet/GrowShop
@onready var bank_page = $PageNet/Bank

# Reference to the PC building that opened this UI (for distance check)
var pc_ref = null

# Timer for checking player distance
var check_distance_timer: float = 0.0


# Initializes the computer UI
func _ready():
	visible = false
	print("[ComputerUI] Started")
	
	# Connect signals only if not already connected
	if close_button and not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)
	if iconet and not iconet.pressed.is_connected(_on_iconet_pressed):
		iconet.pressed.connect(_on_iconet_pressed)
	
	if search_button and not search_button.pressed.is_connected(_on_search_pressed):
		search_button.pressed.connect(_on_search_pressed)
	if exchange_button and not exchange_button.pressed.is_connected(_on_exchange_pressed):
		exchange_button.pressed.connect(_on_exchange_pressed)
	if growshop_button and not growshop_button.pressed.is_connected(_on_growshop_pressed):
		growshop_button.pressed.connect(_on_growshop_pressed)
	if bank_button and not bank_button.pressed.is_connected(_on_bank_pressed):
		bank_button.pressed.connect(_on_bank_pressed)
	
	hide_all_pages()
	print("[ComputerUI] Ready")


# Closes UI if player moves more than 3 cells away
func _process(delta):
	if visible:
		check_distance_timer += delta
		if check_distance_timer >= 0.5:
			check_distance_timer = 0.0
			
			var player = get_tree().get_first_node_in_group("player")
			if player and pc_ref:
				var dist = player.global_position.distance_to(pc_ref.global_position)
				var dist_cells = dist / 16.0
				
				if dist_cells > 3.0:
					print("[ComputerUI] Player moved too far, closing")
					visible = false
					if page_desktop:
						page_desktop.visible = true
						page_net.visible = false


# Sets reference to the PC building
func set_pc_ref(pc_node):
	pc_ref = pc_node


# Hides all darknet content pages
func hide_all_pages():
	if search_page:
		search_page.visible = false
	if exchange_page:
		exchange_page.visible = false
	if growshop_page:
		growshop_page.visible = false
	if bank_page:
		bank_page.visible = false


# Highlights the active navigation button
func set_button_active(button, active: bool):
	if button:
		if active:
			button.add_theme_color_override("font_color", Color(1, 1, 0))
		else:
			button.add_theme_color_override("font_color", Color(1, 1, 1))


# Opens the Search page
func _on_search_pressed():
	print("[ComputerUI] Search pressed")
	hide_all_pages()
	if search_page:
		search_page.visible = true
	set_button_active(search_button, true)
	set_button_active(exchange_button, false)
	set_button_active(growshop_button, false)
	set_button_active(bank_button, false)


# Opens the Exchange page (currency conversion)
func _on_exchange_pressed():
	print("[ComputerUI] Exchange pressed")
	hide_all_pages()
	if exchange_page:
		exchange_page.visible = true
	set_button_active(search_button, false)
	set_button_active(exchange_button, true)
	set_button_active(growshop_button, false)
	set_button_active(bank_button, false)


# Opens the GrowShop page (buy seeds and equipment)
func _on_growshop_pressed():
	print("[ComputerUI] GrowShop pressed")
	hide_all_pages()
	if growshop_page:
		growshop_page.visible = true
		if growshop_page.has_method("show_plants_page"):
			growshop_page.show_plants_page()
	set_button_active(search_button, false)
	set_button_active(exchange_button, false)
	set_button_active(growshop_button, true)
	set_button_active(bank_button, false)


# Opens the Bank page (investments)
func _on_bank_pressed():
	print("[ComputerUI] Bank pressed")
	hide_all_pages()
	if bank_page:
		bank_page.visible = true
	set_button_active(search_button, false)
	set_button_active(exchange_button, false)
	set_button_active(growshop_button, false)
	set_button_active(bank_button, true)


# Enters darknet mode
func _on_iconet_pressed():
	print("[ComputerUI] Iconet pressed - entering darknet")
	if page_net and page_desktop:
		page_net.visible = true
		page_desktop.visible = false
		_on_search_pressed()


# Closes the UI on ESC key
func _input(event):
	if event.is_action_pressed("cancel") and visible:
		print("[ComputerUI] ESC pressed - closing")
		visible = false
		if page_desktop:
			page_desktop.visible = true
			page_net.visible = false
		update_main_ui_money()
		get_viewport().set_input_as_handled()


# Closes the UI via close button
func _on_close_pressed():
	print("[ComputerUI] Close button pressed")
	visible = false
	if page_desktop:
		page_desktop.visible = true
		page_net.visible = false
	update_main_ui_money()


# Updates money displays in the main UI
func update_main_ui_money():
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		if ui.has_method("update_money"):
			ui.update_money()
		if ui.has_method("update_card_money"):
			ui.update_card_money()


# Sets shop data for the growshop
func set_shop_data(_shop_data: Dictionary, pc_node = null):
	print("[ComputerUI] set_shop_data called")
	if pc_node:
		set_pc_ref(pc_node)
