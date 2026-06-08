extends Panel

@onready var energy_bar = $Energy
@onready var sleep_bar = $Sleep

var sleep_depletion_timer: float = 0.0
var sleep_depletion_interval: float = 60.0

func _ready():
	update_energy()
	update_sleep()
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		energy_bar.mouse_entered.connect(_on_energy_hover.bind(ui))
		energy_bar.mouse_exited.connect(_on_energy_hover_end.bind(ui))
		sleep_bar.mouse_entered.connect(_on_sleep_hover.bind(ui))
		sleep_bar.mouse_exited.connect(_on_sleep_hover_end.bind(ui))

func _process(delta):
	sleep_depletion_timer += delta
	if sleep_depletion_timer >= sleep_depletion_interval:
		sleep_depletion_timer = 0.0
		if GameManager.sleep > 0:
			GameManager.use_sleep(1)

func _on_energy_hover(ui: CanvasLayer):
	var text = "Energy: " + str(GameManager.energy) + "/" + str(GameManager.max_energy)
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, energy_bar.global_position)

func _on_energy_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func _on_sleep_hover(ui: CanvasLayer):
	var text = "Sleep: " + str(GameManager.sleep) + "/" + str(GameManager.max_sleep) + "\nAt 0 you pass out"
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, sleep_bar.global_position)

func _on_sleep_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func update_energy():
	if energy_bar:
		var percent = int((float(GameManager.energy) / GameManager.max_energy) * 100)
		energy_bar.value = percent
		var label = energy_bar.get_node_or_null("Label")
		if label:
			label.text = str(percent) + "%"

func update_sleep():
	if sleep_bar:
		var percent = int((float(GameManager.sleep) / GameManager.max_sleep) * 100)
		sleep_bar.value = percent
		var label = sleep_bar.get_node_or_null("Label")
		if label:
			label.text = str(percent) + "%"
