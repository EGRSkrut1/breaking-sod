extends Node
class_name BuildManager

signal build_item_selected(item)
signal build_item_cleared
signal watering_mode_toggled(enabled)

var selected_build_item: String = ""
var watering_mode: bool = false

func select_build_item(item: String):
	selected_build_item = item
	watering_mode = false
	build_item_selected.emit(item)
	print("[BuildManager] Selected item: ", item)

func clear_build_item():
	selected_build_item = ""
	build_item_cleared.emit()
	print("[BuildManager] Cleared selection")

func toggle_watering_mode():
	watering_mode = !watering_mode
	if watering_mode:
		selected_build_item = ""
	watering_mode_toggled.emit(watering_mode)
	print("[BuildManager] Watering mode: ", watering_mode)

func is_watering_mode() -> bool:
	return watering_mode

func get_selected_item() -> String:
	return selected_build_item

func reset():
	selected_build_item = ""
	watering_mode = false
