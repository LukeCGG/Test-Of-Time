extends CanvasLayer

func _ready() -> void:
	get_tree().paused = true
	$VBoxContainer/Quit.grab_focus()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ESC"):
		print("test")
		get_tree().paused = false
		visible = false
		queue_free()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/menus_and_ui/MainMenu.tscn")
	queue_free()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()
