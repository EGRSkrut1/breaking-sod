extends CanvasLayer

var current_map_exit = null
var current_map_name: String = ""

@onready var city_button = $Maps/City/Enter
@onready var forest_button = $Maps/Forest/Enter
@onready var close_button = $CloseButton

var check_distance_timer: float = 0.0

func _ready():
	visible = false
	
	if city_button:
		city_button.pressed.connect(_on_city_pressed)
	if forest_button:
		forest_button.pressed.connect(_on_forest_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func _process(delta):
	if visible and current_map_exit:
		check_distance_timer += delta
		if check_distance_timer >= 0.5:
			check_distance_timer = 0.0
			
			var player = get_tree().get_first_node_in_group("player")
			if player and current_map_exit:
				var dist = player.global_position.distance_to(current_map_exit.global_position)
				var dist_cells = dist / 16.0
				
				if dist_cells > 3.0:
					print("[MapChoiceUI] Player moved too far, closing")
					_on_close_pressed()

func set_current_map_exit(map_exit):
	current_map_exit = map_exit
	current_map_name = get_current_scene_name()
	update_buttons()

func get_current_scene_name() -> String:
	var scene = get_tree().current_scene
	if scene:
		var path = scene.scene_file_path
		if "forest" in path:
			return "forest"
		if "city" in path:
			return "city"
	return ""

func update_buttons():
	if forest_button:
		forest_button.disabled = (current_map_name == "forest")
		if forest_button.disabled:
			forest_button.modulate = Color(0.5, 0.5, 0.5, 1)
		else:
			forest_button.modulate = Color(1, 1, 1, 1)
	
	if city_button:
		city_button.disabled = (current_map_name == "city")
		if city_button.disabled:
			city_button.modulate = Color(0.5, 0.5, 0.5, 1)
		else:
			city_button.modulate = Color(1, 1, 1, 1)

func _on_city_pressed():
	if current_map_name == "city":
		return
	if current_map_exit:
		current_map_exit.change_map("res://maps/city/city.tscn")
		_on_close_pressed()

func _on_forest_pressed():
	if current_map_name == "forest":
		return
	if current_map_exit:
		current_map_exit.change_map("res://maps/forest/forest.tscn")
		_on_close_pressed()

func _on_close_pressed():
	visible = false

func _input(event):
	if event.is_action_pressed("cancel") and visible:
		_on_close_pressed()
		get_viewport().set_input_as_handled()
