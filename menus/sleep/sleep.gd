extends CanvasLayer

@onready var awake_label = $Panel/AwakeLabel
@onready var slept_label = $Panel/SleptLabel
@onready var earned_label = $Panel/EarnedLabel
@onready var spent_label = $Panel/SpentLabel
@onready var day_label = $Panel/DayLabel
@onready var time_label = $Panel/TimeLabel
@onready var close_button = $Panel/CloseButton

var hours_awake: int = 0
var hours_slept: int = 0
var money_earned: int = 0
var money_spent: int = 0
var was_game_playing: bool = true

func _ready():
	visible = false
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func show_sleep_screen():
	print("[Sleep] show_sleep_screen called")
	was_game_playing = GameManager.game_time_timer_active
	GameManager.game_time_timer_active = false
	
	_update_stats()
	visible = true
	_block_input(true)
	print("[Sleep] Sleep screen visible")

func _update_stats():
	hours_awake = 48 - GameManager.sleep
	hours_slept = hours_awake / 2
	hours_slept = int(clamp(hours_slept, 4.0, 24.0))
	
	print("[Sleep] Hours awake: ", hours_awake, " Hours slept: ", hours_slept)
	
	if awake_label:
		awake_label.text = "Time awake: " + str(hours_awake) + " hours"
	if slept_label:
		slept_label.text = "Will sleep: " + str(hours_slept) + " hours"
	if earned_label:
		earned_label.text = "Earned: +$0"
	if spent_label:
		spent_label.text = "Spent: -$0"
	if day_label:
		day_label.text = "Day: " + str(GameManager.game_day)
	if time_label:
		time_label.text = "Time: " + str(GameManager.game_hours).pad_zeros(2) + ":" + str(GameManager.game_minutes).pad_zeros(2)

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

func _on_close_pressed():
	print("[Sleep] Close button pressed")
	GameManager.game_time_timer_active = was_game_playing
	visible = false
	_block_input(false)
	queue_free()

func _input(event):
	if event.is_action_pressed("cancel") and visible:
		print("[Sleep] ESC pressed, closing")
		_on_close_pressed()
		get_viewport().set_input_as_handled()
