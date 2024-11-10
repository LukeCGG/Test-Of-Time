extends Node2D

@onready var spawn: Marker2D = $Spawn
@export var player: PackedScene = preload("res://assets/player/Player.tscn")

func _ready() -> void:
	var instance = player.instantiate()
	instance.position = spawn.position
	add_child(instance)
