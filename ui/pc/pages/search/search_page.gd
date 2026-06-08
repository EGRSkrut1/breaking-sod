extends BasePage
class_name SearchPage

@onready var search_input = $SearchInput
@onready var results_list = $ScrollContainer/ResultsList

# Initializes search page
func _ready():
	print("[SearchPage] Ready")
	if search_input:
		search_input.text_submitted.connect(_on_search)

# Performs search when text is submitted
func _on_search(query: String):
	for child in results_list.get_children():
		child.queue_free()
	
	var results = perform_search(query)
	for result in results:
		var label = Label.new()
		label.text = result
		results_list.add_child(label)
	print("[SearchPage] Searched for: ", query)

# Returns search results based on query
func perform_search(query: String) -> Array:
	var results = []
	var search_term = query.to_lower()
	
	if "green" in search_term or "seed" in search_term:
		results.append("Green Weed Seeds - $10")
		results.append("Grow faster than others")
	if "purple" in search_term:
		results.append("Purple Haze Seeds - $25")
	if "white" in search_term:
		results.append("White Widow Seeds - $50")
	if "graver" in search_term:
		results.append("Graver - $100 - Processing equipment")
	if "dryer" in search_term:
		results.append("Dryer - $200 - Drying equipment")
	if "wrapper" in search_term:
		results.append("Wrapper - $300 - Packaging equipment")
	if "laptop" in search_term:
		results.append("Laptop - $500 - Access to darknet")
	if "bed" in search_term:
		results.append("Bed - $50 - Restore energy")
	
	return results
