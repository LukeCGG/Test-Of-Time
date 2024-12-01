extends Camera2D

@onready var player = $"/root/Level/Player"

func _process(delta: float) -> void:
	position = lerp(position, player.position, 8*delta)
