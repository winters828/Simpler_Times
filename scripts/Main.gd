extends Node2D
# THINK IT, DREAM IT, DO IT. "Just go balls to the walls with it" - anon 
# Art credits: Abraxis, myself

# Bug list ___
# a good way to optimize code is to find any calls to a specific node and store it in a local variable within that function

# To do now ___   			(Consists of the task at hand)

# left off at line...
# 3 - Build UI / line 128
# we have the basis for ground confirmation upon confirmation press, it'll be expanded on as other items are added
# we'll need blueprint level 2 which may get complicated but lock the first tile and spread blueprint amongst a lot of ground 
# when blueprints are placed on Above1a, human ai will take it from there. good fucking luck with that btw

# Artsy section 
# once blueprint placement system is finished, you'll have to create blueprints for each build 
# this means structures too so you'll need to do the bitmasking again (not a big deal)


# 4 - Confirmation button (orders)
# The confirmation button will act in stages. 
# 1. First you can highlight
# 2. pressing confirm once should lock it to that tile for area control
# 3. the dir pad 

# 5 -
# This will likely go into placing items on the map but we haven't gone into that yet




# To do later ___

# A menu button with a menu
# will include, save, exit and possibly a load button. if music and sfx, on and off buttons for those too

# Identification window
# when a tile is highlighted, return the information of what's on those coordinates.
# The orders list should come with the ability to cancel blueprints but we'll get there eventually

# Second layer/items -
# blocks, colliding tiles on the tilemap
# mountain(rock) blocks, building blocks, doors

# Items, non-colliding items on tilemap
# maybe we can pass off grass this way
# you included a good base layer of the tile map but there needs to be a second layer for
# trees, mountains (clusters of rock tiles), fishing spots, building blocks, walls etc..
# This will be a major development, probably save this for when everything else is finished.

# People -
# Creating people, adding and removing nodes
# Then path finding for said people

# Environment -
# Animals for food of course

# Trees for wood. 

# At some point perhaps in the far future you can create a seasonal system too.
# you have the time of the seasons, you just need a weather system


# Ideas ___ (concepts for future developments)
# Rivers - You can somewhat make them already, but maybe through placement instead of scaling 
# Map customization - Actually making a map of your own and then saving it for future use
# Salting - A cool concept would be salting food to make it last longer (instead of only freezing it like rimworld)
# This would implying getting salt from rock or even pure salt blocks (maybe even use it as a currency in a fun twist)
# Boats - maybe for fishing

# Programming Ideas ___ (to help optimize code)
# Have a condition that activates the storing of a specific tile(type Vector2) in order to keep track of the condition of that tile. 
# This way we can keep track of tiles that need special attention more easily 
# This may mean many for loops that itterate through this array causing more processing (according to big O notation)

# Code starts here --------------------------------------------------------------------------------------------------------
# Constant variables | 75*128=9600 tiles
const WIDTH = 75
const HEIGHT = 128
var highlight = Vector2(0,0) # relative to entire map, current highlight marker position
var highlight_lock = Vector2(0,0) # A locked position to compare with the updated highlight 
var ltp = Vector2(0,0) # Last Touched Position relative to where on the screen
var lcp = Vector2(0,0) # Last Camera Position used to tell if the camera is moving
var camlock = false
var blueprint_lvl = 0 # each level of the blueprint placement system 
var build_sys_lvl = 0 # each level of the build system related to ui, important as it gives the same buttons different purposes
var blueprint_id = [-1,-1,-1] # Wtf godot, fix your ID system! blueprint_id[0] for blueprint layer and blueprint_id[1] for Above1a layer
# blueprint_id[3] determines what type of ground it the build tile can be placed on (any ground = 0, shoal = 1)

# Test variables (delete if not in use)

# _input() and _ready() are the two primary events for this script
# Calls _world_generation() upon loading the scene
func _ready():
	_world_generation()

# The entire UI / There's probably a better way to organize and divide this up in scripts...
func _input(event):
	print(blueprintground_check())
	# User is pressing a button
	if ui_pressed($PCamera/HUD/UI):
		$PCamera.position = lcp # Stops screen dragging through a UI button 
		if event is InputEventScreenTouch and event.is_pressed():
			dir_pad_control()
			ui_control()
	
	# User pressing anything other than UI (map pressing), allow the continuation of highlighting tiles
	if not ui_pressed($PCamera/HUD/UI): # combine these two if statements?
		if event is InputEventScreenTouch and event.is_pressed(): #is_pressed() will get rid of repeated _input() function calls
			ltp = $Ground0.world_to_map((event).position) # last touched screen position
			highlight_marker_update(event)
			
			# Just an info label that shows what tile is being touched on the map (can be deleted when not needed)
			$PCamera/HUD/Info.text = str($Ground0.world_to_map($Ground0.make_input_local(event).position)) # Just an info label
			
	
	# User pressing either buttons or map 
		# If highlighter leaves the map it's cleared off (direct touch or pad)
	if $Ground0.get_cellv(highlight) <= 0:
		$Ground0/Controllayer.set_cellv(highlight,-1)
		$Ground0/Blueprint.set_cellv(highlight, -1)
	
		# blueprint_lvl 2.5 allows touch or ui compatibility so it should take place here
		# So we need to fill allowed tiles inbetween these two points with blueprints and delete them when not within said points
		# confirm will set all tiles between these points on above1a and reject will delete all these blueprint and reset the bp lvl
	if blueprint_lvl == 2.5: # maybe also if highlight_lock is active?
		
		pass
	
		# Must be last code in input func to keep track of camera position AFTER any action is taken 
		# If Camera is being moved by dragging, not by ui buttons, delete highlight
	if lcp != $PCamera.position && not ui_pressed($PCamera/HUD/UI):
		$Ground0/Controllayer.set_cellv(highlight,-1)
		$Ground0/Blueprint.set_cellv(highlight, -1)
		highlight = Vector2(-1,-1)
	lcp = $PCamera.position
	



# Keeping the highlight marker updated upon touching the map, works in conjunction with ui_control()
func highlight_marker_update(event):
	
	# if the tile is empty or already contains choosen blueprint and if a build blueprint has been choosen (structure or other)
	if ($Ground0/Blueprint.get_cellv(highlight) == -1 or $Ground0/Blueprint.get_cellv(highlight) == blueprint_id[0]) and (blueprint_lvl == 1 or blueprint_lvl == 2):
		$Ground0/Blueprint.set_cellv(highlight, -1) 
	
	# Highlight placement upon touch (blueprint_level 0) / Before highlight update above
	$Ground0/Controllayer.set_cellv(highlight,-1) # clear the last highlighted cell, must be before new placement
	highlight = $Ground0.world_to_map($Ground0.make_input_local(event).position) # new placement point
	$Ground0/Controllayer.set_cellv(highlight, 0) # Highlight the newly touched cell
	# After highlight update is below
	
	# this as it is won't work, you need to find a way to make this follow the highlight marker only when selected
	# If build_bp has been updated with an ID then blueprint placing is active
	if blueprint_lvl == 1 or blueprint_lvl == 2: $Ground0/Blueprint.set_cellv(highlight, blueprint_id[0]) 
	

# UI button control including build menu level system
func ui_control():
	# When confirm is pressed after a non structure build has been selected
	if $PCamera/HUD/UI/Confirm.is_pressed() and blueprint_lvl == 1: 
		if blueprintground_check():
			$Ground0/Above1a.set_cellv(highlight, blueprint_id[1])
		else:
			$PCamera/HUD/Info.text = "Wrong tile!"
		# only shoal seems to be the only other option for now, until docks and walls on top of docks
	
	# Confirm is pressed after a structure build has selected 
	if $PCamera/HUD/UI/Confirm.is_pressed() and blueprint_lvl == 2:
		# When done, we'll end the if statement setting blueprint_lvl to 2.5
		if blueprintground_check():
			highlight_lock = highlight
			blueprint_lvl = 2.5 # blueprint_lvl 2.5 happens in input() function because ui and touch can be used
		else:
			$PCamera/HUD/Info.text = "Wrong tile!"
	
	# Return is pressed while blueprint level 1, resets all variables in blueprint_id
	if $PCamera/HUD/UI/Return.is_pressed() and (blueprint_lvl == 1 or blueprint_lvl == 2):
		blueprint_lvl = 0
		for value in blueprint_id:
			value = -1
		$Ground0/Blueprint.set_cellv(highlight, -1)
	
	# Back to level 0 from level 1 - Base UI
	if $PCamera/HUD/UI/Return.is_pressed() and build_sys_lvl == 1:
		build_sys_lvl = 0
		$PCamera/HUD/UI/Pad.show()
		$PCamera/HUD/UI/BuildMenu/Categories.hide()
	
	# Entering level 1 - Categories of build options, if blueprint mode is active, Build is deactivated
	if $PCamera/HUD/UI/Build.is_pressed() and build_sys_lvl == 0: # !!!may get rid of now that we can change blueprints
		build_sys_lvl = 1
		$PCamera/HUD/UI/Pad.hide()
		$PCamera/HUD/UI/BuildMenu/Categories.show()
	
	# Back to level 1 from any level 2
	if $PCamera/HUD/UI/Return.is_pressed() and build_sys_lvl == 2:
		build_sys_lvl = 1
		blueprint_lvl = 0
		for builds in $PCamera/HUD/UI/BuildMenu/Builds.get_children(): # hide all builds regardless of picked 
			builds.hide()
		$PCamera/HUD/UI/BuildMenu/Categories.show()
	
	# Entering level 2 - Structure
	if $PCamera/HUD/UI/BuildMenu/Categories/Structure.is_pressed() and build_sys_lvl == 1:
		build_sys_lvl = 2
		blueprint_lvl = 2
		$PCamera/HUD/UI/BuildMenu/Categories.hide()
		$PCamera/HUD/UI/BuildMenu/Builds/Structure.show()
	# Entering level 2 - Production
	if $PCamera/HUD/UI/BuildMenu/Categories/Production.is_pressed() and build_sys_lvl == 1:
		build_sys_lvl = 2
		blueprint_lvl = 1
		$PCamera/HUD/UI/BuildMenu/Categories.hide()
		$PCamera/HUD/UI/BuildMenu/Builds/Production.show()
	# Entering level 2 - Miscellaneous
	if $PCamera/HUD/UI/BuildMenu/Categories/Miscellaneous.is_pressed() and build_sys_lvl == 1:
		build_sys_lvl = 2
		blueprint_lvl = 1
		$PCamera/HUD/UI/BuildMenu/Categories.hide()
		$PCamera/HUD/UI/BuildMenu/Builds/Miscellaneous.show()
	
	# left off here, Just (yah.. just) have to make blueprint on the map of this selection now
	# If a lvl 2 button was pressed
	if build_sys_lvl == 2: # Just to save running through for loops every time
		for categories in $PCamera/HUD/UI/BuildMenu/Builds.get_children():
			for selection in categories.get_children():
				if selection.is_pressed():
					# Goes back to Build sys level 0 then selects blueprint ID to set build_bp to
					build_sys_lvl = 0 
					for builds in $PCamera/HUD/UI/BuildMenu/Builds.get_children(): # hide all builds regardless of picked 
						builds.hide()
					$PCamera/HUD/UI/Pad.show()
					blueprint_ID()
	

# Sets the build blueprint IDs of the blueprint selected including ground verification in index [2] 
func blueprint_ID(): # New builds added here!
	if $PCamera/HUD/UI/BuildMenu/Builds/Miscellaneous/Campfire.is_pressed(): # Campfire build selected 
		blueprint_id[0] = 0 # Godot's terrible ID system needs me to distinguish items between an ID for the blueprint layer
		blueprint_id[1] = 5 # and an ID for the Above1a ground layer, when placement is confirmed 
		blueprint_id[2] = 0 # 2nd index refers to where this tile can be constructed (ground verification)
	if $PCamera/HUD/UI/BuildMenu/Builds/Structure/WoodWall.is_pressed(): # blueprint = 1 above1a = 2 anyground 0
		blueprint_id[0] = 1
		blueprint_id[1] = 2
		blueprint_id[2] = 0
	
	if highlight != Vector2(-1,-1): $Ground0/Blueprint.set_cellv(highlight, blueprint_id[0]) 

# Directional pad's combined effect on camera and highlight marker positions (also camlock button)
func dir_pad_control():
	if $PCamera/HUD/UI/Pad/Up.is_pressed():
		if blueprint_lvl == 1: $Ground0/Blueprint.set_cellv(highlight,-1) # clear last highlighted possible blueprint
		$Ground0/Controllayer.set_cellv(highlight,-1) # clear the last highlighted cell
		highlight.y-=1
		if camlock: # unfortuantely complex ternary operators don't work in gdscript
			$PCamera.position.y-=16 
		else: 
			ltp.y-=2 # should put this back by itself if you don't end up usind camlock
		if ltp.y < 3 && camlock == false: # if you reach the edge of the screen in this direction, camera follows highlighter
			$PCamera.position.y-=16
			ltp.y+=2
		$Ground0/Controllayer.set_cellv(highlight, 0)
		if blueprint_lvl == 1: $Ground0/Blueprint.set_cellv(highlight, blueprint_id[0]) # place active blueprint if there is one
	
	if $PCamera/HUD/UI/Pad/Down.is_pressed(): 
		if blueprint_lvl == 1: $Ground0/Blueprint.set_cellv(highlight,-1) # clear last highlighted possible blueprint
		$Ground0/Controllayer.set_cellv(highlight,-1)
		highlight.y+=1
		if camlock: 
			$PCamera.position.y+=16
		else:
			ltp.y+=2
		if ltp.y > 60 && camlock == false: 
			$PCamera.position.y+=16
			ltp.y-=2
		$Ground0/Controllayer.set_cellv(highlight, 0)
		if blueprint_lvl == 1: $Ground0/Blueprint.set_cellv(highlight, blueprint_id[0]) 
	
	if $PCamera/HUD/UI/Pad/Left.is_pressed():
		if blueprint_lvl == 1: $Ground0/Blueprint.set_cellv(highlight,-1) # clear last highlighted possible blueprint
		$Ground0/Controllayer.set_cellv(highlight,-1) 
		highlight.x-=1
		if camlock: 
			$PCamera.position.x-=16
		else:
			ltp.x-=2
		if ltp.x < 3 && camlock == false: 
			$PCamera.position.x-=16
			ltp.x+=2
		$Ground0/Controllayer.set_cellv(highlight, 0)
		if blueprint_lvl == 1: $Ground0/Blueprint.set_cellv(highlight, blueprint_id[0]) 
	
	if $PCamera/HUD/UI/Pad/Right.is_pressed():
		if blueprint_lvl == 1: $Ground0/Blueprint.set_cellv(highlight,-1) # clear last highlighted possible blueprint
		$Ground0/Controllayer.set_cellv(highlight,-1) 
		highlight.x+=1
		if camlock: 
			$PCamera.position.x+=16
		else:
			ltp.x+=2
		if ltp.x > 34 && camlock == false: 
			$PCamera.position.x+=16
			ltp.x-=2
		$Ground0/Controllayer.set_cellv(highlight, 0)
		if blueprint_lvl == 1: $Ground0/Blueprint.set_cellv(highlight, blueprint_id[0]) 
	
	# Camlock
	if $PCamera/HUD/UI/Pad/Camlock.is_pressed(): 
		camlock = true if camlock == false else camlock == false

# Blue print Ground check, returns true when a currently selected blueprint can be built on a currently highlighted tile 
func blueprintground_check():
	# highlighted cell is ground and blueprint is allowed on all ground types
	if $Ground0.get_cellv(highlight) >= 8 && blueprint_id[2] == 0: return true
	

# Uses recursion to go through a branch (UI in this case) and returns true if a UI button is pressed
func ui_pressed(node):
	for SubN in node.get_children():
		if SubN is TouchScreenButton and SubN.is_pressed(): # if this works try combining them 
			return true
		if SubN.get_child_count() > 0 and ui_pressed(SubN):
			return true

# Takes the Global(Welt) tile_index array from the picture created in NewGameMenu.gd and creates a map out of it
func _world_generation():
	var randx = 0 # for random autotile selection of tiles
	var rnum = RandomNumberGenerator.new()
	rnum.randomize() # Clearly a random number generator, used for what though?
	var i = 0 # Going through the entire tile_index
	# Laying out the tiles
	for x in WIDTH:
		for y in HEIGHT:
			# Uses autotile to select randomly from a atlas STAYS WITH SETTING CELL
			# maybe not for now, but if you do more autotiling than ground, you may need to specify which index
			if rnum.randf_range(0,1) > .98: randx = 1
			elif rnum.randf_range(0,1) < .02: randx = 2
			else: randx = 0
			# Final decided tile/autotile
			$Ground0.set_cellv(Vector2(x, y), Welt.tile_index[i], false, false, false, Vector2(randx,0)) # was randx
			i+=1
	
	$Ground0.update_bitmask_region() 


