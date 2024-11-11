extends Node2D

@onready var spawn: Marker2D = $Spawn
@export var player_scene: PackedScene = preload("res://assets/player/Player.tscn")

func _ready() -> void:
	var player = player_scene.instantiate()
	player.position = spawn.position
	add_child(player)
