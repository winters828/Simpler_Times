extends Camera2D

# x = 74 y = 127
# The grey box limits are the ones that follow the current camera

var touch_vector = Vector2()
var primary_touch = false
var events = {}
var zoom_sensitivity = 10
var zoom_speed = 0.05
var last_drag_distance = 0
var min_zoom = 0.25
var max_zoom = 1

# All camera related input 
func _input(event):
	# Used to reset after a drag(pan) or zoom
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
	
	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			if not primary_touch:
				# Still works without this part of the if statement 
				touch_vector = event.get_relative()
				primary_touch = true
			else:
				var result = event.get_relative()*3 - touch_vector
				set_position(get_position() + (result*-1)) # multiplying by negative inverts the direction
				primary_touch = false
				# Godot doesn't have working camera limits, so I had to make them
				if self.position.x < -650:
					self.position.x = -650
				if self.position.x > 650:
					self.position.x = 650
				if self.position.y < -940:
					self.position.y = -940
				if self.position.y > 940:
					self.position.y = 940
				
		elif events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
				new_zoom = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
				zoom = Vector2.ONE * new_zoom
				last_drag_distance = drag_distance
		get_tree().set_input_as_handled() # also still works without it
	

# temp button that will help you gauge the values of map generation 
func _on_DebugBack_released():
	get_tree().change_scene("res://scenes/NewGameMenu.tscn")
