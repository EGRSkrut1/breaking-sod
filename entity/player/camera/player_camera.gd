extends Node
class_name PlayerCamera

var camera: Camera2D = null
var zoom_min: float = 0.5
var zoom_max: float = 2.0
var zoom_speed: float = 0.05
var default_zoom: float = 1.0

# Sets up camera with reference and limits
func setup(camera_node: Camera2D):
	camera = camera_node
	if camera:
		camera.zoom = Vector2(default_zoom, default_zoom)
		camera.limit_left = -100000
		camera.limit_top = -100000
		camera.limit_right = 100000
		camera.limit_bottom = 100000
		camera.position_smoothing_enabled = true
		print("[PlayerCamera] Setup complete")

# Handles mouse wheel zoom input
func process_input(event):
	if event is InputEventMouseButton and camera:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom += Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom -= Vector2(zoom_speed, zoom_speed)
	
	if camera:
		camera.zoom.x = clamp(camera.zoom.x, zoom_min, zoom_max)
		camera.zoom.y = clamp(camera.zoom.y, zoom_min, zoom_max)
