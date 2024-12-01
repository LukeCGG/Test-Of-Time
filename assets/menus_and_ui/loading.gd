extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label
var sizing = 0
var loadText = true

func _ready() -> void:
	while loadText:
		label.text = "Loading."
		await get_tree().create_timer(0.5).timeout
		label.text = "Loading.."
		await get_tree().create_timer(0.5).timeout
		label.text = "Loading..."
		await get_tree().create_timer(0.5).timeout

func _physics_process(delta: float) -> void:
	if color_rect.rotation_degrees < 360:
		color_rect.rotation_degrees += 2
	else:
		color_rect.rotation_degrees = 0
	if sizing == 0:
		if color_rect.scale.x < 2:
			color_rect.scale.x = lerp(color_rect.scale.x, 2.1, 2 * delta)
			color_rect.scale.y = lerp(color_rect.scale.y, 2.1, 2 * delta)
		else:
			sizing = 1
	else:
		if color_rect.scale.x > 1:
			color_rect.scale.x = lerp(color_rect.scale.x, 0.9, 2 * delta)
			color_rect.scale.y = lerp(color_rect.scale.y, 0.9, 2 * delta)
		else:
			sizing = 0
