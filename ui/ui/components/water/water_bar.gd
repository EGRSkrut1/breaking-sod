extends Panel

@onready var progress_bar = $ProgressBar

func _ready():
	if progress_bar:
		progress_bar.min_value = 0
		progress_bar.max_value = 50
		progress_bar.value = 50
		progress_bar.step = 1
		
		var bg_style = StyleBoxFlat.new()
		bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
		progress_bar.add_theme_stylebox_override("background", bg_style)
		
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = Color(0.2, 0.5, 0.8, 0.8)
		progress_bar.add_theme_stylebox_override("fill", fill_style)
	
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		progress_bar.mouse_entered.connect(_on_water_hover.bind(ui))
		progress_bar.mouse_exited.connect(_on_water_hover_end.bind(ui))
	
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("get_current_water"):
		var water_manager = main_node.get_node_or_null("WaterManager")
		if water_manager:
			water_manager.water_changed.connect(_on_water_changed)
	
	update_water()

func _on_water_changed(current: int, max: int):
	if progress_bar:
		progress_bar.max_value = max
		progress_bar.value = current

func _on_water_hover(ui: CanvasLayer):
	var main_node = get_tree().current_scene
	var current = 0
	var max_water = 0
	if main_node and main_node.has_method("get_current_water") and main_node.has_method("get_max_water"):
		current = main_node.get_current_water()
		max_water = main_node.get_max_water()
	
	var text = "Water: " + str(current) + "/" + str(max_water) + "\nRefill at well"
	if ui and ui.has_method("show_tooltip_at_position"):
		ui.show_tooltip_at_position(text, progress_bar.global_position)

func _on_water_hover_end(ui: CanvasLayer):
	if ui and ui.has_method("hide_tooltip"):
		ui.hide_tooltip()

func update_water():
	if not progress_bar:
		return
	
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("get_current_water") and main_node.has_method("get_max_water"):
		progress_bar.max_value = main_node.get_max_water()
		progress_bar.value = main_node.get_current_water()
