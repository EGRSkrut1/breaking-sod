extends CanvasLayer

@onready var resolution_option = $Panel/ResolutionOption
@onready var vsync_option = $Panel/VsyncOption
@onready var volume_slider = $Panel/VolumeSlider
@onready var language_option = $Panel/LanguageOption
@onready var close_button = $Panel/CloseButton

func _ready():
	print("[Settings] Started")
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	load_settings()
	visible = false
	print("[Settings] Ready")

func load_settings():
	print("[Settings] Loading settings")

func save_settings():
	print("[Settings] Saving settings")

func apply_settings():
	print("[Settings] Applying settings")

func _on_close_pressed():
	print("[Settings] Close pressed")
	visible = false

func _input(event):
	if event.is_action_pressed("cancel") and visible:
		visible = false
		get_viewport().set_input_as_handled()
