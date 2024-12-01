extends Node2D

@onready var spawn: Marker2D = $Spawn
#@onready var safe_area: Area2D = $SafeArea
@onready var floors: TileMapLayer = $Tiles/Floor
@export var player_scene: PackedScene = preload("res://assets/player/Player.tscn")
const PLAYER_INVENTORY = preload("res://assets/player/player_inventory.tres")
var coords

func _ready() -> void:
	PLAYER_INVENTORY.items.clear()
	for num in range(16):
		PLAYER_INVENTORY.items.append(null)
	#var player = player_scene.instantiate()
	#player.position = spawn.position
	#add_child(player)
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ESC") and not get_tree().paused:
		if has_node("/root/Level/PauseMenu"):
			return
		else:
			var pause = preload("res://assets/menus_and_ui/PauseMenu.tscn").instantiate()
			get_node("/root/Level").add_child(pause)

func _on_safe_area_body_shape_entered(body_rid: RID, body: TileMapLayer, _body_shape_index: int, _local_shape_index: int) -> void:
	coords = body.get_coords_for_body_rid(body_rid)
	#print(coords)
	#floors.blockages.append(coords)
	#print(body.get_cell_tile_data(coords))
	#body.get_cell_tile_data(coords).set_navigation_polygon(0, null)
	#body.get_cell_atlas_coords(coords)
	#body.get_cell_tile_data(body.local_to_map(coords*16)).set_navigation_polygon(0, null)
