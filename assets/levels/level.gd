extends Node2D

@onready var spawn: Marker2D = $Spawn
#@onready var safe_area: Area2D = $SafeArea
@onready var floors: TileMapLayer = $Tiles/Floor
@export var player_scene: PackedScene = preload("res://assets/player/Player.tscn")

var coords

func _ready() -> void:
	var player = player_scene.instantiate()
	player.position = spawn.position
	add_child(player)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ESC") and not get_tree().paused:
		var pause = preload("res://assets/menus_and_ui/PauseMenu.tscn").instantiate()
		get_tree().get_root().add_child(pause)

func _on_safe_area_body_shape_entered(body_rid: RID, body: TileMapLayer, _body_shape_index: int, _local_shape_index: int) -> void:
	pass
	coords = body.get_coords_for_body_rid(body_rid)
	print(coords)
	#floors.blockages.append(coords)
	#print(body.get_cell_tile_data(coords))
	#body.get_cell_tile_data(coords).set_navigation_polygon(0, null)
	#body.get_cell_atlas_coords(coords)
	#body.get_cell_tile_data(body.local_to_map(coords*16)).set_navigation_polygon(0, null)
