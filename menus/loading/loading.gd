extends CanvasLayer

signal loading_complete

var min_display_time: float = 3.0
var start_time: float = 0.0
var scene_ready: bool = false
var timer_running: bool = false
var target_scene_path: String = ""

func _ready():
	visible = false

func start_load(scene_path: String):
	target_scene_path = scene_path
	_show_loading()

func _show_loading():
	start_time = Time.get_ticks_msec() / 1000.0
	scene_ready = false
	timer_running = true
	visible = true
	# CanvasLayer has no z_index, it's always on top by default
	_block_input(true)
	print("[Loading] Show loading at: ", start_time)
	
	ResourceLoader.load_threaded_request(target_scene_path)
	
	await get_tree().create_timer(min_display_time).timeout
	timer_running = false
	_check_complete()

func _check_complete():
	var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
	print("[Loading] Check - Elapsed: ", elapsed, " Timer running: ", timer_running)
	
	var status = ResourceLoader.load_threaded_get_status(target_scene_path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		scene_ready = true
		print("[Loading] Scene loaded")
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("[Loading] Failed to load: ", target_scene_path)
		_hide_loading()
		return
	
	if scene_ready and not timer_running:
		_hide_loading()

func _hide_loading():
	print("[Loading] Hiding loading")
	visible = false
	_block_input(false)
	
	var new_scene = ResourceLoader.load_threaded_get(target_scene_path)
	if new_scene:
		get_tree().change_scene_to_packed(new_scene)
	
	loading_complete.emit()

func _block_input(block: bool):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if block:
			player.set_process_input(false)
			player.set_physics_process(false)
			player.set_process_unhandled_input(false)
		else:
			player.set_process_input(true)
			player.set_physics_process(true)
			player.set_process_unhandled_input(true)
	
	var scene = get_tree().current_scene
	if scene:
		if block:
			scene.set_process_input(false)
			scene.set_process_unhandled_input(false)
		else:
			scene.set_process_input(true)
			scene.set_process_unhandled_input(true)
