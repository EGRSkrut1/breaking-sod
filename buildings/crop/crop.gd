extends StaticBody2D

var is_planted: bool = false
var current_plant: Node = null
var cell_pos: Vector2 = Vector2.ZERO
var water_intensity: float = 0.0
var is_watered: bool = false
var is_watering_in_progress: bool = false
var watering_timer: float = 0.0
var watering_duration: float = 1.0
var player_ref = null

@onready var anim_sprite = $AnimatedSprite2D

func _ready():
	add_to_group("crops")
	draw_soil()
	print("[Crop] Started")

func set_cell_pos(pos: Vector2):
	cell_pos = pos

func get_cell_pos() -> Vector2:
	return cell_pos

func draw_soil():
	if not anim_sprite or not anim_sprite.sprite_frames:
		return
	
	if is_watered and anim_sprite.sprite_frames.has_animation("watered soil"):
		anim_sprite.play("watered soil")
		anim_sprite.stop()
		anim_sprite.frame = 0
	elif anim_sprite.sprite_frames.has_animation("soil"):
		anim_sprite.play("soil")
		anim_sprite.stop()
		anim_sprite.frame = 0

func set_watered(watered: bool):
	is_watered = watered
	draw_soil()

func plant_seed(seed_type: String):
	if is_planted:
		return
	
	current_plant = PlantManager.create_plant(seed_type)
	if not current_plant:
		return
	
	add_child(current_plant)
	await get_tree().process_frame
	is_planted = true
	
	if current_plant and current_plant.has_method("show_planted_animation"):
		current_plant.show_planted_animation()
	
	print("[Crop] Planted seed: ", seed_type)

func harvest():
	if not is_planted or not current_plant:
		return
	
	if current_plant.is_ready_to_harvest():
		var item = {
			"type": current_plant.plant_type,
			"name": current_plant.get_plant_name(),
			"price": current_plant.get_sell_value()
		}
		GameManager.add_inventory_item(item)
		GameManager.add_sold_plant(current_plant.plant_type)
		
		var ui = get_tree().current_scene.get_node_or_null("UI")
		if ui and ui.has_method("show_floating_text"):
			ui.show_floating_text("+" + item["name"] + " +$" + str(item["price"]), Color(0, 1, 0, 1), global_position + Vector2(0, -40))
		
		current_plant.queue_free()
		current_plant = null
		is_planted = false
		water_intensity = 0.0
		is_watered = false
		draw_soil()
		print("[Crop] Harvested: ", item["name"])

func _process(delta):
	if is_watering_in_progress and player_ref:
		watering_timer += delta
		if watering_timer >= watering_duration:
			finish_watering()

func start_watering(player):
	if is_watering_in_progress:
		return
	
	if not is_planted or not current_plant:
		return
	
	is_watering_in_progress = true
	player_ref = player
	watering_timer = 0.0
	
	if player_ref:
		player_ref.velocity = Vector2.ZERO
		player_ref.set_physics_process(false)

func finish_watering():
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref = null
	
	is_watering_in_progress = false
	
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("get_current_water") and main_node.has_method("use_water"):
		if main_node.get_current_water() >= 10:
			if current_plant and current_plant.has_method("water"):
				current_plant.water()
			main_node.use_water()
			is_watered = true
			draw_soil()
			
			if current_plant and current_plant.has_method("play_water_animation"):
				current_plant.play_water_animation()
			
			await get_tree().create_timer(5.0).timeout
			is_watered = false
			draw_soil()
			if main_node.has_method("save_all_crops"):
				main_node.save_all_crops()
			if main_node.has_method("save_water_state"):
				main_node.save_water_state()

func water():
	if is_watering_in_progress:
		return
	
	if not is_planted or not current_plant:
		return
	
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("get_current_water"):
		if main_node.get_current_water() < 10:
			return
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		start_watering(player)

func _on_plant_died():
	current_plant = null
	is_planted = false
	water_intensity = 0.0
	is_watered = false
	draw_soil()
