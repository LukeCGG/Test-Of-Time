extends Area2D

var Item : bool = true ## Registered as Item for player

@onready var sprite_2d: Sprite2D = $Sprite2D

@export_enum("Chalk", "Lantern", "Boots", "Money") var item : String = "Chalk"

func _ready() -> void:
	sprite_2d.rotation_degrees = randf_range(-50,50)
	if item == "Chalk":
		sprite_2d.texture = load("res://assets/levels/Chalk.png")
	if item == "Lantern":
		sprite_2d.texture = load("res://assets/levels/Lantern.png")
	if item == "Boots":
		sprite_2d.texture = load("res://assets/levels/Boots.png")
	if item == "Money":
		sprite_2d.texture = load("res://assets/levels/Money.png")
