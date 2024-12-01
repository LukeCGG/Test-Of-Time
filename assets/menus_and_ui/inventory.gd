extends CanvasLayer

@onready var player: CharacterBody2D = $"/root/Level/Player"
var autoclose : bool = false

func _ready() -> void:
	get_tree().paused = true
	$Control/HealthBar.max_value = player.maxHealth
	$Control/HealthBar.value = player.health
	if $Control.get_child(1).name == "HBoxContainer":
		for slot in $Control/HBoxContainer/PlayerInventory.get_children():
			#slot.connect('slot_changed', _change_detected)
			pass
	else:
		for slot in $Control/PlayerInventory.get_children():
			#slot.connect('slot_changed', _change_detected)
			pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("INTERACT"):
		#print("disable inv")
		await _change_detected()
		get_tree().paused = false
		queue_free()
		
func _change_detected():
	#print("Changes")
	player._check_upgrades()
	return 'completed'
