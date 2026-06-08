extends Node
class_name PreviewManager

var preview_node: Sprite2D = null
var parent_node: Node2D = null

var crop_texture = null
var plant_textures = {}
var building_textures = {}

func setup(parent: Node2D):
	parent_node = parent
	print("[PreviewManager] Setup complete")

func update_preview(build_item: String, watering_mode: bool, grid_x: int, grid_y: int, is_in_range: bool):
	if build_item == "" and not watering_mode:
		clear_preview()
		return
	
	if grid_x < 0 or grid_x >= 25 or grid_y < 0 or grid_y >= 25:
		if preview_node:
			preview_node.visible = false
		return
	
	var world_pos = Vector2(grid_x * 16, grid_y * 16)
	
	if not preview_node:
		create_preview_node()
	
	preview_node.visible = true
	preview_node.position = world_pos + Vector2(8, 8)
	
	if watering_mode:
		set_watering_preview()
	elif build_item == "crop":
		set_crop_preview()
	elif build_item in ["green", "purple", "white"]:
		set_plant_preview(build_item)
	else:
		set_building_preview(build_item)
	
	if not is_in_range:
		preview_node.visible = false

func create_preview_node():
	preview_node = Sprite2D.new()
	preview_node.modulate = Color(1, 1, 1, 0.5)
	preview_node.z_index = 1000
	preview_node.centered = true
	parent_node.add_child(preview_node)
	print("[PreviewManager] Preview node created")

func clear_preview():
	if preview_node:
		preview_node.queue_free()
		preview_node = null
		print("[PreviewManager] Preview cleared")

func set_watering_preview():
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0.5, 0.8, 0.4))
	preview_node.texture = ImageTexture.create_from_image(img)
	preview_node.scale = Vector2(1, 1)

func set_crop_preview():
	preview_node.scale = Vector2(0.013, 0.02)
	var tex = get_crop_preview_texture()
	if tex:
		preview_node.texture = tex

func set_plant_preview(plant_type: String):
	preview_node.scale = Vector2(0.2, 0.2)
	preview_node.position.y += 8
	var tex = get_plant_preview_texture(plant_type)
	if tex:
		preview_node.texture = tex

func set_building_preview(building_type: String):
	preview_node.scale = Vector2(0.029, 0.029)
	var tex = get_building_preview_texture(building_type)
	if tex:
		preview_node.texture = tex

func get_crop_preview_texture():
	if crop_texture:
		return crop_texture
	
	var path = "res://buildings/crop/crop.tscn"
	if not FileAccess.file_exists(path):
		return null
	
	var scene = load(path)
	if not scene:
		return null
	
	var temp = scene.instantiate()
	parent_node.add_child(temp)
	temp.process_mode = Node.PROCESS_MODE_DISABLED
	
	var sprite = temp.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = temp.get_node_or_null("Sprite2D")
	
	if sprite is AnimatedSprite2D and sprite.sprite_frames and sprite.sprite_frames.has_animation("soil"):
		crop_texture = sprite.sprite_frames.get_frame_texture("soil", 0)
	elif sprite is Sprite2D and sprite.texture:
		crop_texture = sprite.texture
	
	temp.queue_free()
	return crop_texture

func get_plant_preview_texture(plant_type: String):
	if plant_textures.has(plant_type):
		return plant_textures[plant_type]
	
	var path = "res://plants/base/base_plant.tscn"
	if not FileAccess.file_exists(path):
		return null
	
	var scene = load(path)
	if not scene:
		return null
	
	var temp = scene.instantiate()
	parent_node.add_child(temp)
	temp.process_mode = Node.PROCESS_MODE_DISABLED
	
	var plant_script_path = "res://plants/" + plant_type + "/" + plant_type + "_plant.gd"
	if FileAccess.file_exists(plant_script_path):
		var plant_script = load(plant_script_path)
		if plant_script:
			temp.set_script(plant_script)
	
	if temp.has_method("set_type"):
		temp.set_type(plant_type)
	
	var sprite = temp.get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.sprite_frames:
		var preview_anim = plant_type + "_seed"
		if sprite.sprite_frames.has_animation(preview_anim):
			plant_textures[plant_type] = sprite.sprite_frames.get_frame_texture(preview_anim, 0)
	
	temp.queue_free()
	return plant_textures.get(plant_type, null)

func get_building_preview_texture(building_type: String):
	if building_textures.has(building_type):
		return building_textures[building_type]
	
	var path = "res://buildings/" + building_type + "/" + building_type + ".tscn"
	
	if building_type == "pc":
		path = "res://buildings/pc/pc.tscn"
	
	if building_type == "atm":
		path = "res://buildings/atm/atm.tscn"
	
	if not FileAccess.file_exists(path):
		return null
	
	var scene = load(path)
	if not scene:
		return null
	
	var temp = scene.instantiate()
	parent_node.add_child(temp)
	temp.process_mode = Node.PROCESS_MODE_DISABLED
	
	var sprite = temp.get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = temp.get_node_or_null("Sprite2D")
	
	if sprite is AnimatedSprite2D and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		building_textures[building_type] = sprite.sprite_frames.get_frame_texture("idle", 0)
	elif sprite is Sprite2D and sprite.texture:
		building_textures[building_type] = sprite.texture
	
	temp.queue_free()
	return building_textures.get(building_type, null)
