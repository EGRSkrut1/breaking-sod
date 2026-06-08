extends CharacterBody2D

@export var speed: float = 200.0

@onready var movement = $Movement
@onready var interaction = $Interaction
@onready var camera_manager = $CameraManager
@onready var inventory_manager = $InventoryManager

# Initializes player and all sub-components
func _ready():
	add_to_group("player")
	print("[Player] Started")
	
	if movement:
		movement.setup(self, speed)
	if interaction:
		interaction.setup(self)
	if camera_manager:
		camera_manager.setup($Camera2D)
	if inventory_manager:
		inventory_manager.setup()
	
	print("[Player] Ready")

# Called by input system to handle interaction
func interact():
	print("[Player] Interact called")
	if interaction:
		interaction.interact_with_crop()
		interaction.interact_with_building()
		interaction.interact_with_customer()

# Updates player movement every physics frame
func _physics_process(delta):
	if movement:
		movement.process_movement(delta)

# Handles input events
func _input(event):
	if event.is_action_pressed("interact"):
		print("[Player] Interact button pressed")
		interact()
	
	if camera_manager:
		camera_manager.process_input(event)

# Sets currently selected seed type
func set_selected_seed(seed_type: String):
	if inventory_manager:
		inventory_manager.set_selected_seed(seed_type)

# Returns currently selected seed type
func get_selected_seed() -> String:
	if inventory_manager:
		return inventory_manager.get_selected_seed()
	return "green"
