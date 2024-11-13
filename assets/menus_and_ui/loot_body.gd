extends Control

@onready var acc_quip_inventory: InventoryContainer = $AccQuipInventory

func _ready() -> void:
	pass # If looting body, acc_quip_inventory.visible = true
