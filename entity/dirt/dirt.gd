extends StaticBody2D

var cell_pos: Vector2 = Vector2.ZERO
var type: String = "dirt"
var hp: int = 3
var energy_cost: int = 10
var is_hovered: bool = false

@onready var anim_sprite = $AnimatedSprite2D
@onready var hp_label = $HPLabel
@onready var dig_label = $DigLabel

func _ready():
	add_to_group("dirt")
	update_visual()
	
	print("[Dirt] Started at position: ", cell_pos)
	
	if hp_label:
		hp_label.visible = false
	if dig_label:
		dig_label.visible = false
	
	var collision = $CollisionShape2D
	if collision and collision.shape is RectangleShape2D:
		collision.shape.size = Vector2(16, 16)
	
	var mouse_area = $MouseDetector
	if not mouse_area:
		mouse_area = Area2D.new()
		mouse_area.name = "MouseDetector"
		var mouse_collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(16, 16)
		mouse_collision.shape = shape
		mouse_area.add_child(mouse_collision)
		add_child(mouse_area)
	
	mouse_area.mouse_entered.connect(_on_mouse_entered)
	mouse_area.mouse_exited.connect(_on_mouse_exited)
	
	z_index = 0

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func set_type(new_type: String):
	type = new_type
	if type == "dirt":
		hp = 3
		energy_cost = 10
	elif type == "stone":
		hp = 5
		energy_cost = 20
	update_visual()

func update_visual():
	if anim_sprite:
		if type == "dirt":
			if anim_sprite.sprite_frames.has_animation("dirt"):
				anim_sprite.play("dirt")
		elif type == "stone":
			if anim_sprite.sprite_frames.has_animation("stone"):
				anim_sprite.play("stone")

func update_hover_labels():
	if is_hovered:
		if hp_label:
			hp_label.text = "HP: " + str(hp)
			hp_label.visible = true
		if dig_label:
			dig_label.text = "Left Click - Dig"
			dig_label.visible = true

func mine():
	if GameManager.energy < energy_cost:
		print("[Dirt] Not enough energy! Need: ", energy_cost, " Have: ", GameManager.energy)
		return
	
	GameManager.use_energy(energy_cost)
	
	hp -= 1
	print("[Dirt] Mined! HP left: ", hp)
	
	if hp <= 0:
		destroy()
	else:
		update_visual()
		update_hover_labels()

func destroy():
	var drops = get_drops()
	for drop in drops:
		GameManager.add_inventory_item(drop)
		
		var ui = get_tree().current_scene.get_node_or_null("UI")
		if ui and ui.has_method("show_floating_text"):
			ui.show_floating_text("+" + drop["name"] + " +$" + str(drop["price"]), Color(0.5, 0.5, 0.8, 1), global_position + Vector2(0, -40))
		
		print("[Dirt] Found: ", drop["name"])
	
	var basement_map = get_tree().current_scene
	if basement_map and basement_map.has_method("remove_dirt"):
		basement_map.remove_dirt(cell_pos.x, cell_pos.y)
	
	queue_free()

func get_drops() -> Array:
	var drops = []
	var drop_chance = randi() % 100
	
	if type == "dirt":
		if drop_chance < 5:
			drops.append(ItemDatabase.get_item("old_coin"))
		elif drop_chance < 8:
			drops.append(ItemDatabase.get_item("crystal"))
		elif drop_chance < 15:
			drops.append(ItemDatabase.get_item("tin_can"))
	else:
		if drop_chance < 3:
			drops.append(ItemDatabase.get_item("old_coin"))
		elif drop_chance < 5:
			drops.append(ItemDatabase.get_item("crystal"))
		elif drop_chance < 10:
			drops.append(ItemDatabase.get_item("tin_can"))
	
	return drops

func _on_mouse_entered():
	is_hovered = true
	update_hover_labels()
	z_index = 10

func _on_mouse_exited():
	is_hovered = false
	if hp_label:
		hp_label.visible = false
	if dig_label:
		dig_label.visible = false
	z_index = 0

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var dist = global_position.distance_to(mouse_pos)
		if dist < 20:
			mine()
			get_viewport().set_input_as_handled()
