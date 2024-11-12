extends Line2D

func _ready() -> void:
	SignalBus.connect('newGeneration', _age_line)

func _age_line():
	#print("Line Aging")
	default_color = Color(default_color.r, default_color.g, default_color.b, default_color.a - 0.30)
	if default_color.a <= 0:
		queue_free()
