extends Control

const LOADING_SCREEN = preload("res://assets/menus_and_ui/LoadingScreen.tscn")

func _ready() -> void:
	$MarginContainer/VBoxContainer/Play.grab_focus()

#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed('PLAYER_UP'):
#		pass

func _on_play_pressed() -> void:
	LoadManager.load_scene("res://assets/levels/TestLevel01.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/menus_and_ui/OptionsMenu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
