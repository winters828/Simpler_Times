extends Node
# As you add more features such as biomes and land features, you'll be able to add
# them to this menu as a part of map generation, including mountains and trees

# Object creation
var _image = Image.new()
var _texture = ImageTexture.new() 
var open_simplex_noise

# Map generation variables (If these work out, we won't need the ones in Welt anymore)
# Keep them at their starting spinbox values
var sleed = 0
var per = 10
var oct = 0
var dec = 0
const TILES = { # You can't include numbers in the string for some reason
	# You need a whole new ID for a replacement because godot
	'ground': 9,
	'tfp': 2,
	'fp': 10,
	'full': 4,
	'sfp': 5,
	'Shoal': 6,
	'Sea': 7,
	'beach': 8,
	
}

# Just draw map once to initialize map_data array
func _ready():
	_draw_map()

func _draw_map():
	
	# Use the HEX string for colors, the float values don't work for some reason
	_image.create(75,128,false,Image.FORMAT_RGBA8)
	_image.lock()
	
	# Noise process
	# Creates a new noise object, creates random seed if 0 else applies user input
	randomize() # applies all noise variables 
	open_simplex_noise = OpenSimplexNoise.new()
	
	if sleed == 0:
		open_simplex_noise.seed = randi()
	else: 
		open_simplex_noise.seed = sleed
	open_simplex_noise.octaves = oct
	open_simplex_noise.period = per
	open_simplex_noise.lacunarity = 1 # These two should stay static
	open_simplex_noise.persistence = 1
	
	# needs to change the picture when the variable changes
	# All pixel changes need to be in this loop
	Welt.tile_index.clear()
	for x in range(75):
		for y in range(128):
			var ti = _get_tile_index(open_simplex_noise.get_noise_2d(float(x), float(y)))
			Welt.tile_index.append(ti)
			#print(TILES.ground)
			
			if ti == TILES.ground:
				_image.set_pixel(x,y,Color( 0.803922, 0.521569, 0.247059, 1))
			elif ti == TILES.beach:
				_image.set_pixel(x,y,Color( 0.941176, 0.901961, 0.54902, 1))
			elif ti == TILES.Shoal:
				_image.set_pixel(x,y,Color(0.0, 1, 1, 1))
			elif ti == TILES.Sea:
				_image.set_pixel(x,y,Color(0.0, 0.0, 1, 1))
	
	_texture.create_from_image(_image)
	$MenuBackground2/MapOutline/MapViewer.set_texture(_texture)
	_image.unlock()

func _get_tile_index(noise_sample):
	# Fix the ever living shit out of this mess
	# maybe just see if adding to some variable will help this
	if noise_sample < (-0.05 + dec):
		return TILES.ground
	if noise_sample < (0.09 + dec):
		return TILES.beach # you'll replace this with sand later and move fp up in code
	if noise_sample < (0.21 + dec):
		return TILES.Shoal
	return TILES.Sea

func _on_BackButton_released():
	get_tree().change_scene("res://scenes/Menu.tscn")

# You may need more than a scene change in the future
# You'll need to look into the Resource manager class and maybe make a loading screen
func _on_StartButton_released():
	get_tree().change_scene("res://scenes/GameMap.tscn")

func _on_Period_value_changed(value):
	per = value
	_draw_map()

func _on_Octaves_value_changed(value):
	oct = value
	_draw_map()

func _on_Seed_value_changed(value):
	sleed = value
	_draw_map()

# Balance of ground and water on the map
func _on_line_value_changed(value):
	# value will be 1-10
	dec = value/300
	_draw_map()



# Goodbye grass!
#	if noise_sample < -0.3:
#		return TILES.full
#	if noise_sample < -0.23:
#		return TILES.sfp
#	if noise_sample < -0.17:
#		return TILES.fp
