extends Panel

@onready var text_label = $Label

var hide_timer: float = 0.0
var is_visible_forced: bool = false

func _ready():
	visible = false
	
	modulate = Color(1, 1, 1, 1)
	
	if text_label:
		text_label.anchor_left = 0.0
		text_label.anchor_top = 0.0
		text_label.anchor_right = 1.0
		text_label.anchor_bottom = 1.0
		text_label.offset_left = 8
		text_label.offset_top = 4
		text_label.offset_right = -8
		text_label.offset_bottom = -4
		text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		text_label.add_theme_font_size_override("font_size", 12)
		text_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func show_tooltip(text: String, pos: Vector2):
	text_label.text = text
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var tooltip_pos = mouse_pos + Vector2(15, 25)
	
	var viewport_size = viewport.get_visible_rect().size
	if tooltip_pos.x + size.x > viewport_size.x:
		tooltip_pos.x = mouse_pos.x - size.x - 15
	if tooltip_pos.y + size.y > viewport_size.y:
		tooltip_pos.y = mouse_pos.y - size.y - 15
	if tooltip_pos.x < 0:
		tooltip_pos.x = 5
	if tooltip_pos.y < 0:
		tooltip_pos.y = 5
	
	global_position = tooltip_pos
	visible = true
	is_visible_forced = false

func show_permanent_tooltip(text: String, pos: Vector2):
	text_label.text = text
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var tooltip_pos = mouse_pos + Vector2(15, 25)
	
	var viewport_size = viewport.get_visible_rect().size
	if tooltip_pos.x + size.x > viewport_size.x:
		tooltip_pos.x = mouse_pos.x - size.x - 15
	if tooltip_pos.y + size.y > viewport_size.y:
		tooltip_pos.y = mouse_pos.y - size.y - 15
	if tooltip_pos.x < 0:
		tooltip_pos.x = 5
	if tooltip_pos.y < 0:
		tooltip_pos.y = 5
	
	global_position = tooltip_pos
	visible = true
	is_visible_forced = true

func hide_tooltip():
	visible = false
	text_label.text = ""

func hide_tooltip_delayed():
	hide_timer = 0.5

func _process(delta):
	if hide_timer > 0:
		hide_timer -= delta
		if hide_timer <= 0:
			visible = false
			text_label.text = ""
