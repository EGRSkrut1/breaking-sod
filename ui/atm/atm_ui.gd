extends CanvasLayer

# Reference to exchange button
@onready var exchange_button = $Exchange/ExchangeButton

# Reference to direction toggle button
@onready var to_button = $Exchange/to

# Reference to amount input field
@onready var line_edit = $Exchange/LineEdit

# Reference to close button
@onready var close_button = $CloseButton

# Current transfer direction: "to_card" or "to_cash"
var current_direction: String = "to_card"

# Reference to the ATM building
var atm_ref = null

# Timer for auto-close when player moves away
var check_distance_timer: float = 0.0


# Called when ATM UI is loaded
func _ready():
	visible = false
	
	# Connect button signals
	if exchange_button:
		exchange_button.pressed.connect(_on_exchange_pressed)
	if to_button:
		to_button.pressed.connect(_on_to_pressed)
		to_button.text = ">"
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if line_edit:
		line_edit.text_submitted.connect(_on_exchange_pressed)


# Closes UI if player moves more than 3 cells away
func _process(delta):
	if visible:
		check_distance_timer += delta
		if check_distance_timer >= 0.5:
			check_distance_timer = 0.0
			
			var player = get_tree().get_first_node_in_group("player")
			if player and atm_ref:
				var dist = player.global_position.distance_to(atm_ref.global_position)
				var dist_cells = dist / 16.0
				
				if dist_cells > 3.0:
					print("[AtmUI] Player moved too far, closing")
					visible = false


# Sets reference to the ATM building
func set_atm_ref(atm_node):
	atm_ref = atm_node


# Toggles transfer direction between cash->card and card->cash
func _on_to_pressed():
	if current_direction == "to_card":
		current_direction = "to_cash"
		to_button.text = "<"
	else:
		current_direction = "to_card"
		to_button.text = ">"


# Processes the money transfer
func _on_exchange_pressed():
	var text = line_edit.text.strip_edges()
	if text == "":
		return
	
	var amount = int(text.replace("$", ""))
	if amount <= 0:
		return
	
	if current_direction == "to_card":
		if GameManager.money >= amount:
			GameManager.money -= amount
			GameManager.card_money += amount
			line_edit.text = ""
			update_ui_money()
	else:
		if GameManager.card_money >= amount:
			GameManager.card_money -= amount
			GameManager.money += amount
			line_edit.text = ""
			update_ui_money()


# Updates money displays in the main UI
func update_ui_money():
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		if ui.has_method("update_money"):
			ui.update_money()
		if ui.has_method("update_card_money"):
			ui.update_card_money()


# Closes the ATM UI
func _on_close_pressed():
	visible = false


# Closes on ESC key
func _input(event):
	if event.is_action_pressed("cancel") and visible:
		_on_close_pressed()
		get_viewport().set_input_as_handled()
