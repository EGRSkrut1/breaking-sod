extends Node2D

@onready var label = $Label

var velocity: Vector2 = Vector2(0, -50)
var lifetime: float = 1.5

func setup(text: String, color: Color):
	if not label:
		label = $Label
		if not label:
			label = Label.new()
			add_child(label)
	
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", color)
	label.position = Vector2(-30, -20)
	
	var viewport = get_viewport()
	if viewport:
		var camera = viewport.get_camera_2d()
		if camera:
			var canvas_transform = camera.get_canvas_transform()
			position = global_position - canvas_transform.get_origin()
	
	var tree = get_tree()
	if tree:
		var timer = tree.create_timer(lifetime)
		timer.timeout.connect(queue_free)

func _process(delta):
	position += velocity * delta
	velocity.y -= 10 * delta
