extends Area2D

var Item : bool = true ## Registered as Item for player
var type

@onready var sprite_2d: Sprite2D = $Sprite2D

@export_enum("Chalk", "Lantern", "Light Boots", "Money", "Key") var item : String = "Chalk"

func _ready() -> void:
	sprite_2d.rotation_degrees = randf_range(-50,50)
	if item == "Chalk":
		sprite_2d.texture = load("res://assets/levels/Chalk.png")
		type = preload("res://assets/levels/item_Chalk.tres")
	if item == "Lantern":
		sprite_2d.texture = load("res://assets/levels/Lantern.png")
		type = preload("res://assets/levels/item_Lantern.tres")
	if item == "Light Boots":
		sprite_2d.texture = load("res://assets/levels/Boots.png")
		type = preload("res://assets/levels/item_Boots.tres")
	if item == "Money":
		sprite_2d.texture = load("res://assets/levels/Money.png")
		type = preload("res://assets/levels/item_Money.tres")
	if item == "Key":
		sprite_2d.texture = load("res://assets/levels/Key.png")
		type = preload("res://assets/levels/item_Key.tres")
		
func _removal():
	queue_free()
