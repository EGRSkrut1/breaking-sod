extends Node

var save_timer: float = 0.0
var save_interval: float = 300.0
var is_game_playing: bool = true

func _ready():
	print("[AutoSave] Started, interval: ", save_interval, " seconds")

func _process(delta):
	if is_game_playing:
		save_timer += delta
		if save_timer >= save_interval:
			save_timer = 0.0
			auto_save()

func auto_save():
	print("[AutoSave] Auto-saving...")
	
	var forest = get_tree().current_scene
	
	if forest and forest.has_method("save_all_crops"):
		forest.save_all_crops()
	
	if forest and forest.has_method("save_water_state"):
		forest.save_water_state()
	
	if forest and forest.has_method("get_current_water"):
		var water_data = {
			"max_water_units": forest.get_max_water(),
			"current_water_units": forest.get_current_water()
		}
		GameManager.save_water_data(water_data)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameManager.player_position = player.global_position
		print("[AutoSave] Player position saved: ", GameManager.player_position)
	
	GameManager.save_game()
	print("[AutoSave] Auto-save complete")

func on_game_paused():
	is_game_playing = false
	print("[AutoSave] Game paused, auto-save disabled")

func on_game_resumed():
	is_game_playing = true
	save_timer = 0.0
	print("[AutoSave] Game resumed, auto-save enabled")

func manual_save():
	print("[AutoSave] Manual save triggered")
	auto_save()
