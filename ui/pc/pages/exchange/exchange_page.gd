extends BasePage
class_name ExchangePage

@onready var exchange_button = $ExchangeButton
@onready var to_button = $To
@onready var line_edit = $LineEdit

var current_direction: String = "to_card"

# Initializes exchange page
func _ready():
	print("[ExchangePage] Ready")
	if exchange_button:
		exchange_button.pressed.connect(_on_exchange_pressed)
	if to_button:
		to_button.pressed.connect(_on_to_pressed)
		to_button.text = ">"
	if line_edit:
		line_edit.text_submitted.connect(_on_exchange_pressed)

# Toggles transfer direction between cash->card and card->cash
func _on_to_pressed():
	if current_direction == "to_card":
		current_direction = "to_cash"
		to_button.text = "<"
		print("[ExchangePage] Direction changed to: card to cash")
	else:
		current_direction = "to_card"
		to_button.text = ">"
		print("[ExchangePage] Direction changed to: cash to card")

# Processes money transfer
func _on_exchange_pressed():
	var text = line_edit.text.strip_edges()
	if text == "":
		print("[ExchangePage] Empty input")
		return
	
	var amount = int(text.replace("$", ""))
	if amount <= 0:
		print("[ExchangePage] Invalid amount")
		return
	
	if current_direction == "to_card":
		if GameManager.money >= amount:
			GameManager.money -= amount
			GameManager.card_money += amount
			line_edit.text = ""
			update_money_displays()
			print("[ExchangePage] Transferred ", amount, " cash to card")
		else:
			print("[ExchangePage] Not enough cash")
	else:
		if GameManager.card_money >= amount:
			GameManager.card_money -= amount
			GameManager.money += amount
			line_edit.text = ""
			update_money_displays()
			print("[ExchangePage] Transferred ", amount, " from card to cash")
		else:
			print("[ExchangePage] Not enough card money")

# Updates money displays in main UI
func update_money_displays():
	var main = get_tree().current_scene
	var ui = main.get_node_or_null("UI")
	if ui:
		if ui.has_method("update_money"):
			ui.update_money()
		if ui.has_method("update_card_money"):
			ui.update_card_money()
