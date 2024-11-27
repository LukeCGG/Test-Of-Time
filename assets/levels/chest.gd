extends Area2D

var Interactable : bool = true ## For player to detect as interactable
@export var InvInst : Inventory
@export var maxLootAmount : int = 3

#Loot Table Items
const ITEM_BOOTS = preload("res://assets/levels/item_Boots.tres")
const ITEM_CHALK = preload("res://assets/levels/item_Chalk.tres")
const ITEM_LANTERN = preload("res://assets/levels/item_Lantern.tres")
const ITEM_MONEY = preload("res://assets/levels/item_Money.tres")

func _ready() -> void:
	if InvInst == null:
		InvInst = Inventory.new()
		for i in range(16):
			if randi_range(1,10) > 7 and maxLootAmount > 0:
				maxLootAmount -= 1
				var item = randi_range(1,4)
				if item == 1:
					InvInst.items.append(ITEM_BOOTS)
				elif item == 2:
					InvInst.items.append(ITEM_CHALK)
				elif item == 3:
					InvInst.items.append(ITEM_LANTERN)
				elif item == 4:
					InvInst.items.append(ITEM_MONEY)
			else:
				InvInst.items.append(null)
