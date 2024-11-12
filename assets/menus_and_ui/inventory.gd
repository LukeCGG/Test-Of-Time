extends CanvasLayer

func _ready() -> void:
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("INVENTORY"):
		print("disable inv")
		get_tree().paused = false
		queue_free()
