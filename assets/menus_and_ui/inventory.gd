extends CanvasLayer

const PLAYER_INVENTORY = preload("res://assets/player/player_inventory.tres")
@onready var player: CharacterBody2D = $"/root/Level/Player"
const ITEM_CHALK = preload("res://assets/levels/item_Chalk.tres")
var autoclose : bool = false

func _ready() -> void:
	get_tree().paused = true
	if $Control.get_child(0).name == "HBoxContainer":
		for slot in $Control/HBoxContainer/PlayerInventory.get_children():
			#slot.connect('slot_changed', _change_detected)
			pass
	else:
		for slot in $Control/PlayerInventory.get_children():
			#slot.connect('slot_changed', _change_detected)
			pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("INVENTORY"):
		#print("disable inv")
		await _change_detected()
		get_tree().paused = false
		queue_free()
		
func _change_detected():
	#print("Changes")
	player._check_upgrades()
	return 'completed'
