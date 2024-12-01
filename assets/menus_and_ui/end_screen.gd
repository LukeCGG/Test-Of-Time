extends Control

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/menus_and_ui/MainMenu.tscn")
	get_tree().paused = false
	queue_free()
