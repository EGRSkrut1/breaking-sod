extends Node2D
class_name BasePlant

var plant_type: String = ""
var current_stage: int = -1
var is_mature: bool = false
var water_count: int = 0
var required_water: int = 0
var growth_time: float = 0.0
var total_stages: int = 6
var is_growing: bool = false
var can_be_watered: bool = true
var overall_progress: float = 0.0
var growth_timer: Timer
var wither_timer: float = 60.0
var is_withering: bool = false
var last_water_time: float = 0.0
var wither_start_time: float = 0.0
var wither_duration: float = 5.0

@onready var anim_sprite = $AnimatedSprite2D
@onready var progress_bar = $ProgressBar
@onready var water_icon = $WaterIcon
@onready var progress_label = null

func _ready():
	scale = Vector2(1, 1)
	
	if water_icon:
		water_icon.scale = Vector2(0.05, 0.05)
	
	if anim_sprite:
		anim_sprite.stop()
		anim_sprite.frame = 0
		anim_sprite.frame_progress = 0.0
	
	if progress_bar:
		progress_bar.visible = false
		progress_bar.value = 0
		progress_label = progress_bar.get_node_or_null("Label")
		if progress_label == null:
			progress_label = Label.new()
			progress_label.name = "Label"
			progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			progress_label.add_theme_font_size_override("font_size", 8)
			progress_bar.add_child(progress_label)
	
	if water_icon:
		water_icon.visible = false
		if water_icon is AnimatedSprite2D and water_icon.sprite_frames and water_icon.sprite_frames.has_animation("water"):
			water_icon.play("water")
	
	var mouse_area = $MouseDetector
	if mouse_area:
		mouse_area.mouse_entered.connect(_on_mouse_entered)
		mouse_area.mouse_exited.connect(_on_mouse_exited)
	
	last_water_time = Time.get_ticks_msec() / 1000.0
	print("[BasePlant] Started, type: ", plant_type)

func _process(_delta):
	if is_mature:
		return
	
	if is_growing:
		return
	
	if is_withering:
		update_wither_effect()
		return
	
	if not is_mature and not is_growing:
		var current_time = Time.get_ticks_msec() / 1000.0
		var time_since_water = current_time - last_water_time
		
		if time_since_water >= wither_timer:
			start_withering()

func update_wither_effect():
	var current_time = Time.get_ticks_msec() / 1000.0
	var wither_progress = (current_time - wither_start_time) / wither_duration
	
	if wither_progress >= 1.0:
		_on_wither_death()
		return
	
	if anim_sprite:
		var wither_green = 1.0 - wither_progress * 0.7
		var wither_red = 0.5 + wither_progress * 0.5
		var wither_blue = 1.0 - wither_progress * 0.8
		anim_sprite.modulate = Color(wither_red, wither_green, wither_blue, 1.0)
	
	if water_icon:
		var water_red = 0.2 + wither_progress * 0.8
		var water_green = 0.5 - wither_progress * 0.4
		var water_blue = 0.8 - wither_progress * 0.7
		var water_alpha = 0.7 + wither_progress * 0.3
		water_icon.modulate = Color(water_red, water_green, water_blue, water_alpha)

func set_type(seed_type: String):
	plant_type = seed_type
	set_plant_data()
	water_count = 0
	current_stage = -1
	is_mature = false
	is_growing = false
	can_be_watered = true
	overall_progress = 0.0
	is_withering = false
	
	if anim_sprite:
		anim_sprite.modulate = Color(1, 1, 1, 1)
	if water_icon:
		water_icon.modulate = Color(1, 1, 1, 1)
	
	last_water_time = Time.get_ticks_msec() / 1000.0
	
	show_seed()
	update_ui()
	show_planted_animation()

func show_planted_animation():
	if water_icon and water_icon is AnimatedSprite2D:
		water_icon.visible = true
		if water_icon.sprite_frames and water_icon.sprite_frames.has_animation("watered soil"):
			water_icon.play("watered soil")
		else:
			water_icon.play("water")
		await get_tree().create_timer(1.0).timeout
		water_icon.visible = false

func show_seed():
	var anim_name = plant_type + "_seed"
	if anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_name):
		anim_sprite.play(anim_name)
		anim_sprite.stop()
		anim_sprite.frame = 0

func set_plant_data():
	pass

func restore_from_save(saved_progress: float, saved_stage: int, saved_water_count: int, saved_mature: bool, saved_last_water: float):
	overall_progress = saved_progress
	current_stage = saved_stage
	water_count = saved_water_count
	is_mature = saved_mature
	last_water_time = saved_last_water
	
	if is_mature:
		var anim_name = plant_type + "_stage5"
		if anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_name):
			anim_sprite.play(anim_name)
			anim_sprite.stop()
			anim_sprite.frame = 0
		update_ui()
	else:
		if current_stage >= 0:
			set_stage(current_stage)
		else:
			show_seed()
		update_ui()
		if overall_progress > 0 and overall_progress < 1.0 and water_count >= required_water:
			start_growth_from_progress()

func start_growth_from_progress():
	if is_growing or is_mature:
		return
	
	is_growing = true
	
	var target = get_progress_target()
	var start = get_progress_start()
	
	if overall_progress >= target:
		_on_growth_complete()
		return
	
	growth_timer = Timer.new()
	growth_timer.wait_time = 0.1
	growth_timer.one_shot = false
	growth_timer.timeout.connect(_on_growth_update)
	add_child(growth_timer)
	growth_timer.start()
	
	update_stage_from_progress()
	update_ui()

func get_plant_name() -> String:
	return ""

func set_stage(stage: int):
	current_stage = stage
	var anim_name = plant_type + "_stage" + str(current_stage)
	if anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_name):
		anim_sprite.play(anim_name)
		anim_sprite.stop()
		anim_sprite.frame = 0
		anim_sprite.frame_progress = 0.0

func get_preview_animation() -> String:
	return plant_type + "_seed"

func water():
	if is_mature or water_count >= required_water or not can_be_watered:
		return
	
	water_count += 1
	can_be_watered = false
	last_water_time = Time.get_ticks_msec() / 1000.0
	
	if progress_bar:
		progress_bar.visible = false
	
	if is_withering:
		is_withering = false
		if anim_sprite:
			anim_sprite.modulate = Color(1, 1, 1, 1)
		if water_icon:
			water_icon.modulate = Color(1, 1, 1, 1)
		set_stage(current_stage)
	
	var parent_crop = get_parent()
	if parent_crop and parent_crop.has_method("set_watered"):
		parent_crop.set_watered(true)
		await get_tree().create_timer(5.0).timeout
		parent_crop.set_watered(false)
	
	start_growth_from_progress()

func start_withering():
	is_withering = true
	wither_start_time = Time.get_ticks_msec() / 1000.0
	print("[BasePlant] Started withering")

func _on_wither_death():
	if progress_bar:
		progress_bar.visible = false
	if water_icon:
		water_icon.visible = false
	
	var parent = get_parent()
	if parent and parent.has_method("_on_plant_died"):
		parent._on_plant_died()
	
	queue_free()

func get_progress_target() -> float:
	return 1.0

func get_progress_start() -> float:
	return 0.0

func _on_growth_update():
	var target = get_progress_target()
	var start = get_progress_start()
	var phase_range = target - start
	
	var growth_per_tick = (0.1 / growth_time) * phase_range
	overall_progress += growth_per_tick
	
	if overall_progress >= target:
		overall_progress = target
		growth_timer.stop()
		growth_timer.queue_free()
		is_growing = false
		
		update_stage_from_progress()
		
		if water_count >= required_water and overall_progress >= 1.0:
			_on_growth_complete()
		else:
			finish_growth_phase()
		
		var main_node = get_tree().current_scene
		if main_node and main_node.has_method("save_all_crops"):
			main_node.save_all_crops()
	else:
		update_stage_from_progress()
		update_ui()

func update_stage_from_progress():
	var target_stage: int
	if overall_progress < 0.16:
		target_stage = 0
	elif overall_progress < 0.33:
		target_stage = 1
	elif overall_progress < 0.5:
		target_stage = 2
	elif overall_progress < 0.66:
		target_stage = 3
	elif overall_progress < 0.83:
		target_stage = 4
	else:
		target_stage = 5
	
	if target_stage != current_stage:
		set_stage(target_stage)

func finish_growth_phase():
	is_growing = false
	can_be_watered = true
	update_ui()

func _on_growth_complete():
	is_mature = true
	is_growing = false
	can_be_watered = false
	overall_progress = 1.0
	
	if progress_bar:
		progress_bar.visible = false
	if water_icon:
		water_icon.visible = false
	
	var anim_name = plant_type + "_stage5"
	if anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_name):
		anim_sprite.play(anim_name)
		anim_sprite.stop()
		anim_sprite.frame = 0
		anim_sprite.frame_progress = 0.0
	
	print("[BasePlant] Growth complete, mature")

func update_ui():
	if not progress_bar or not water_icon:
		return
	
	if is_mature:
		progress_bar.visible = false
		water_icon.visible = false
		return
	
	if is_growing:
		progress_bar.visible = true
		water_icon.visible = false
		var percent = int(overall_progress * 100)
		progress_bar.value = percent
		
		var bar_color: Color
		if percent < 30:
			bar_color = Color(0.8, 0.2, 0.2, 1)
		elif percent < 70:
			bar_color = Color(0.9, 0.8, 0.2, 1)
		else:
			bar_color = Color(0.2, 0.8, 0.2, 1)
		
		var bar_style = StyleBoxFlat.new()
		bar_style.bg_color = bar_color
		progress_bar.add_theme_stylebox_override("fill", bar_style)
		
		if progress_label:
			if percent >= 100:
				progress_label.text = "READY"
			else:
				progress_label.text = str(percent) + "%"
	
	elif can_be_watered and water_count < required_water:
		progress_bar.visible = false
		water_icon.visible = true
		if water_icon is AnimatedSprite2D and water_icon.sprite_frames and water_icon.sprite_frames.has_animation("water"):
			water_icon.play("water")
	else:
		progress_bar.visible = false
		water_icon.visible = false

func get_sell_value() -> int:
	return 0

func is_ready_to_harvest() -> bool:
	return is_mature

func play_water_animation():
	if water_icon and water_icon is AnimatedSprite2D:
		water_icon.visible = true
		if water_icon.sprite_frames and water_icon.sprite_frames.has_animation("watered soil"):
			water_icon.play("watered soil")
		else:
			water_icon.play("water")
		await get_tree().create_timer(1.0).timeout
		water_icon.visible = false

func _on_mouse_entered():
	var info = {
		"type": plant_type,
		"stage": current_stage,
		"water": water_count,
		"required_water": required_water,
		"is_mature": is_mature,
		"progress": overall_progress
	}
	EventBus.plant_hovered.emit(info, global_position)

func _on_mouse_exited():
	EventBus.plant_hover_hide.emit()
