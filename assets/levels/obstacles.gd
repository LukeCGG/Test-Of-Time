extends TileMapLayer

@onready var walls: TileMapLayer = $"../Walls"
var blockages : Array = []

func _ready() -> void:
	pass

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	blockages = walls.get_used_cells()
	return coords in blockages
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if _use_tile_data_runtime_update(coords): 
		tile_data.set_navigation_polygon(0, null)
