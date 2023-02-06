extends Node

func _on_New_Game_Button_released():
	get_tree().change_scene("res://scenes/NewGameMenu.tscn")

func _on_Load_Button_released():
	get_tree().change_scene("res://scenes/NewGameMenu.tscn")

func _on_Settings_Button_released():
	get_tree().change_scene("res://scenes/SettingsMenu.tscn")
