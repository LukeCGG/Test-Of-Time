extends Button

@onready var tree = $".".get_tree()

@export_file("*.tscn") var scene

func _ready() -> void:
	connect("pressed", _pressed)

func _pressed():
	tree.change_scene_to_file(scene)
