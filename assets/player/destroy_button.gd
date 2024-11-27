extends Button

@onready var player: CharacterBody2D = $"/root/Level/Player"

func _ready() -> void:
	if "Statue" in player.SelectedInv.get_parent():
		visible = true

func _on_pressed() -> void:
	player.SelectedInv.get_parent().lifecycle = 0
	player.SelectedInv.get_parent()._set_weathering()
