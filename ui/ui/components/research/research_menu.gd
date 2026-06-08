extends Panel

# Reference to the research items container
@onready var research_list = $ScrollContainer/ResearchList

# Reference to close button
@onready var close_button = $CloseButton


# Called when research menu is loaded
func _ready():
	visible = false
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)


# Closes the research menu
func _on_close_pressed():
	visible = false
