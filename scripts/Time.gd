extends CanvasModulate

# Day/Night cycle variables
const NIGHT_COLOR = Color("#7b7b7b")
const DAY_COLOR = Color("#ffffff")
var lc = 1 # light change factor
var time = 1080 # start in morning

# Calendar variables
var hr = 0 # game hour
var day = 5
var season = 2 # Win-0 Spring-1 Sum-2 Fall-3

# Day/Night Cycle system
# Full Day = 48 minutes | 1hr = 2 minutes 
# 0 (real seconds) = 0hr (game hours)
# 120 = 1hr 240 = 2hr 360 = 3hr 480 = 4hr 600 = 5hr 720 = 6hr (start of dawn) 840 = 7hr 960 = 8hr 1080 = 9hr (end of dawn)
# 1200 = 10hr 1320 = 11hr 1440 = 12hr 1560 = 13hr 1680 = 14hr 1800 = 15hr 1920 = 16hr 2040 = 17hr 2160 = 18hr (start of dusk)
# 2280 = 19hr 2400 = 20hr 2520 = 21hr (end of dusk) 2640 = 22hr 2760 = 23hr 2880 = 24hr restart timer

# Calendar system 
# Game time system relative to real time (similiar to rimworld)
# 4 seasons = 1 year | season = 15 days (720 minutes)

func _process(delta) -> void:
	time += delta # all time
	
	# Day/Night variables
	# DAWN   720/6hr - 1080/9hr
	if floor(time) > 720 && floor(time) < 1080:
		lc=float((time-720)/360)
		# so the weight(lc) is like a scale between 0-1 between the two color values.
		self.color = NIGHT_COLOR.linear_interpolate(DAY_COLOR, lc) # 0 = night 1 = day
	# DAY
	if floor(time) > 1080 && floor(time) < 2160:
		self.color = DAY_COLOR
	# DUSK
	if floor(time) > 2160 && floor(time) < 2520:
		lc=float((time-2160)/360)
		self.color = DAY_COLOR.linear_interpolate(NIGHT_COLOR, lc)
	# NIGHT
	if floor(time) < 720 || floor(time) > 2520:
		self.color = NIGHT_COLOR
	
	# Calendar variables
	hr = floor(time / 120)
	# New day
	if time > 2880: 
		time = 0 # Start of a new day
		day += 1
	if day > 15:
		day = 1
		if season == 3:
			season = 0
		else:
			season += 1
	get_node("../../PCamera/HUD/Clalender").text = "Season \n" + Welt.seasons[season] + "\nDay: " + str(day) + "\n" + str(hr) + "hr"


# use this button to set the timer to what you want it to be
# use start or some kind of set timer to change the time of day
func _on_TimeSetter_value_changed(value):
	time = value

func _on_Days_value_changed(value):
	day = value
