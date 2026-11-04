extends Node

const SAVE_PATH = "user://save_data.cfg"

var score = 0
var lives = 3

# This stores history across game sessions!
var total_points = 0 

# NEW: Your wallet tracker using the coin values from your mockup
var total_coins = 0

# NEW: Database tracking which ingredients the player owns
var unlocked_ingredients = {
	"falafel": true,        # Default item, always unlocked
	"halloumi": false,      # Costs 2000
	"pickle": false,        # Costs 4000
	"tomato": false         # Costs 8000
}

func _ready():
	load_game()

func reset_game():
	score = 0
	lives = 3

# Saves everything permanently to the user's device
func save_game():
	var config = ConfigFile.new()
	config.set_value("Player", "total_points", total_points)
	# NEW: Save your coins and unlocked list under the "Player" section
	config.set_value("Player", "total_coins", total_coins)
	config.set_value("Player", "unlocked_ingredients", unlocked_ingredients)
	
	var error = config.save(SAVE_PATH)
	if error != OK:
		print("Error saving data!")

# Loads everything automatically when the game boots up
func load_game():
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)
	if error == OK:
		total_points = config.get_value("Player", "total_points", 0)
		# NEW: Fetch coins and unlocked items, or use defaults if they don't exist yet
		total_coins = config.get_value("Player", "total_coins", 0)
		unlocked_ingredients = config.get_value("Player", "unlocked_ingredients", unlocked_ingredients)
	else:
		print("No save file found, starting fresh.")
		total_points = 0
		total_coins = 0
