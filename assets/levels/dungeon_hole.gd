extends Area2D

const PLAYER_INVENTORY = preload("res://assets/player/player_inventory.tres")
var Hole = true
const END_SCREEN = preload("res://assets/menus_and_ui/end_screen.tscn")

func _attempt_leave():
	var HealthText: Label = $"/root/Level/Player/HealthLoss"
	var animation: AnimationPlayer = $"/root/Level/Player/AnimationPlayer"
	#print("attempt leave")
	#Check if key in Inventory
	var key = false
	for i in PLAYER_INVENTORY.items:
		if i != null:
			if i.name == "Secret Key":
				key = true
	#If key in Inventory, Win, else, message
	if key:
		#Win
		#print("Successful leave")
		var end = END_SCREEN.instantiate()
		get_tree().root.add_child(end)
		get_tree().paused = true
		pass
	else:
		#Not yet
		#print("You can't leave yet!")
		HealthText.text = "X"
		animation.play("HealthLoss")
		pass
