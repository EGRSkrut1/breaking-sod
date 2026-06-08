extends Control

@onready var resolution_option = $Panel/ResolutionOption
@onready var vsync_option = $Panel/VsyncOption
@onready var volume_slider = $Panel/VolumeSlider
@onready var language_option = $Panel/LanguageOption
@onready var close_button = $Panel/CloseButton

# Initializes settings menu
func _ready():
	print("[Settings] Started")
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	load_settings()
	print("[Settings] Ready")

# Loads saved settings
func load_settings():
	print("[Settings] Loading settings")

# Saves current settings
func save_settings():
	print("[Settings] Saving settings")

# Applies settings changes
func apply_settings():
	print("[Settings] Applying settings")

# Closes settings menu
func _on_close_pressed():
	print("[Settings] Close pressed")
	queue_free()
