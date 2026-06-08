extends Panel
class_name BasePage

# Base class for all computer pages
func show_page():
	visible = true
	print("[BasePage] Show: ", name)

# Hides the page
func hide_page():
	visible = false
	print("[BasePage] Hide: ", name)

# Updates page data (override in child)
func update_data():
	pass

# Refreshes page content (override in child)
func refresh():
	update_data()
