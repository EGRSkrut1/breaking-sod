extends Panel

@onready var money_label = $MoneyLabel
@onready var card_money_label = $CardMoneyLabel
@onready var suspicion_bar = $Suspicion
@onready var time_label = $calendar/time
@onready var date_label = $calendar/date
@onready var calendar_button = $calendar

func _ready():
	update_money()
	update_card_money()
	update_time()
	update_date()
	update_suspicion()
	
	GameManager.suspicion_changed.connect(update_suspicion)
	GameManager.time_changed.connect(_on_time_changed)
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		calendar_button.mouse_entered.connect(_on_calendar_hover.bind(ui))
		calendar_button.mouse_exited.connect(_on_calendar_hover_end.bind(ui))
		
		suspicion_bar.mouse_entered.connect(_on_suspicion_hover.bind(ui))
		suspicion_bar.mouse_exited.connect(_on_suspicion_hover_end.bind(ui))

func _on_time_changed():
	update_time()
	update_date()

func _on_calendar_hover(ui: CanvasLayer):
	var message = "Day: " + str(GameManager.game_day) + "\n"
	message += "Time: " + str(GameManager.game_hours).pad_zeros(2) + ":" + str(GameManager.game_minutes).pad_zeros(2) + "\n"
	message += "Real time played: " + str(Time.get_ticks_msec() / 60000) + " minutes"
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(message, calendar_button.global_position)

func _on_calendar_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_suspicion_hover(ui: CanvasLayer):
	var text = "Suspicion level: " + str(GameManager.suspicion) + "%\n"
	if GameManager.suspicion >= 75:
		text += "Police will attack on sight!"
	elif GameManager.suspicion >= 50:
		text += "Police may search you randomly!"
	elif GameManager.suspicion >= 25:
		text += "Slightly higher chance of being searched!"
	else:
		text += "You are safe from police attention."
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, suspicion_bar.global_position)

func _on_suspicion_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func update_money():
	if money_label:
		money_label.text = "Cash: $" + str(GameManager.money)

func update_card_money():
	if card_money_label:
		card_money_label.text = "Card: $" + str(GameManager.card_money)

func update_suspicion():
	if suspicion_bar:
		var percent = GameManager.suspicion
		suspicion_bar.value = percent
		var label = suspicion_bar.get_node_or_null("Label")
		if label:
			label.text = str(percent) + "%"
		
		var fill_style = StyleBoxFlat.new()
		if percent > 75:
			fill_style.bg_color = Color(0.8, 0.2, 0.2, 0.8)
		elif percent > 50:
			fill_style.bg_color = Color(0.8, 0.5, 0.2, 0.8)
		elif percent > 25:
			fill_style.bg_color = Color(0.8, 0.8, 0.2, 0.8)
		else:
			fill_style.bg_color = Color(0.2, 0.8, 0.2, 0.8)
		suspicion_bar.add_theme_stylebox_override("fill", fill_style)

func update_time():
	if time_label:
		var hours = GameManager.game_hours
		var minutes = GameManager.game_minutes
		time_label.text = str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2)

func update_date():
	if date_label:
		date_label.text = "Day " + str(GameManager.game_day)

func _on_calendar_pressed():
	var message = "Day: " + str(GameManager.game_day) + "\n"
	message += "Time: " + str(GameManager.game_hours).pad_zeros(2) + ":" + str(GameManager.game_minutes).pad_zeros(2) + "\n"
	message += "Real time played: " + str(Time.get_ticks_msec() / 60000) + " minutes"
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui and ui.has_method("show_permanent_tooltip"):
		ui.show_permanent_tooltip(message, calendar_button.global_position)
