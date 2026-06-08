extends Node

var items = {
	"tin_can": {
		"type": "tin_can",
		"name": "Tin Can",
		"price": 1,
		"description": "A rusty old tin can"
	},
	"old_coin": {
		"type": "old_coin",
		"name": "Old Coin",
		"price": 50,
		"description": "An ancient silver coin"
	},
	"crystal": {
		"type": "crystal",
		"name": "Crystal",
		"price": 100,
		"description": "A rare glowing crystal"
	},
	"crop": {
		"type": "crop",
		"name": "Crop",
		"price": 10,
		"description": "A garden bed for planting"
	},
	"well": {
		"type": "well",
		"name": "Well",
		"price": 25,
		"description": "A water well"
	},
	"graver": {
		"type": "graver",
		"name": "Graver",
		"price": 100,
		"description": "For processing plants"
	},
	"dryer": {
		"type": "dryer",
		"name": "Dryer",
		"price": 200,
		"description": "For drying plants"
	},
	"wrapper": {
		"type": "wrapper",
		"name": "Wrapper",
		"price": 300,
		"description": "For packaging products"
	},
	"laptop": {
		"type": "laptop",
		"name": "Laptop",
		"price": 500,
		"description": "Allows access to darknet"
	},
	"bed": {
		"type": "bed",
		"name": "Bed",
		"price": 50,
		"description": "For resting and restoring energy"
	},
	"basement": {
		"type": "basement",
		"name": "Basement",
		"price": 100,
		"description": "Underground expansion area"
	},
	"green_seed": {
		"type": "green_seed",
		"name": "Green Weed Seeds",
		"price": 10,
		"description": "Fast growth, low price"
	},
	"purple_seed": {
		"type": "purple_seed",
		"name": "Purple Haze Seeds",
		"price": 25,
		"description": "Medium growth, good price"
	},
	"white_seed": {
		"type": "white_seed",
		"name": "White Widow Seeds",
		"price": 50,
		"description": "Slow growth, high price"
	}
}

# Returns item data by type
func get_item(item_type: String) -> Dictionary:
	if items.has(item_type):
		return items[item_type].duplicate()
	return {"type": "unknown", "name": "Unknown", "price": 0, "description": "Unknown item"}

# Returns all items
func get_all_items() -> Dictionary:
	return items
