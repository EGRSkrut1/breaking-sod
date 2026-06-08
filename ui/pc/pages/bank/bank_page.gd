extends BasePage
class_name BankPage

@onready var investment_list = $ScrollContainer/InvestmentList
@onready var balance_label = $BalanceLabel

# Investment options available
var investments = [
	{"name": "Low Risk", "rate": 0.05, "min": 100, "max": 1000},
	{"name": "Medium Risk", "rate": 0.12, "min": 500, "max": 5000},
	{"name": "High Risk", "rate": 0.25, "min": 1000, "max": 10000}
]

# Initializes bank page
func _ready():
	print("[BankPage] Ready")
	update_balance()

# Updates card balance display
func update_balance():
	if balance_label:
		balance_label.text = "Card Balance: $" + str(GameManager.card_money)

# Invests money and adds investment item to inventory
func invest(amount: int, rate: float):
	if GameManager.card_money >= amount:
		GameManager.card_money -= amount
		GameManager.add_inventory_item({"type": "investment", "name": "Investment", "price": int(amount * (1 + rate))})
		update_balance()
		update_money_displays()
		print("[BankPage] Invested $", amount, " at ", rate * 100, "% rate")

# Updates money displays in main UI
func update_money_displays():
	var main = get_tree().current_scene
	var ui = main.get_node_or_null("UI")
	if ui:
		if ui.has_method("update_money"):
			ui.update_money()
		if ui.has_method("update_card_money"):
			ui.update_card_money()
