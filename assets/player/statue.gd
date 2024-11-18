extends StaticBody2D

var Statue : bool = true ## For player to detect as interactable

@export var InvInst : Inventory
#Lives plus 1 for initial death
@export var lifecycle : int = 3 + 1 ## 4 Fresh, 3 Aged, 2 Damaged, 1 Ruined, 0 Crumbled

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $Collision

func _ready() -> void:
	SignalBus.connect('newGeneration', _age_statue)
	_set_weathering()

func _age_statue():
	#age statue
	lifecycle -= 1
	_set_weathering()
	
func _set_weathering():
	if lifecycle == 3:
		sprite.texture = load("res://assets/player/Statue_Aged.png")
	if lifecycle == 2:
		sprite.texture = load("res://assets/player/Statue_Damaged.png")
	if lifecycle == 1:
		sprite.texture = load("res://assets/player/Statue_Ruined.png")
	if lifecycle <= 0:
		collision.disabled = true
		sprite.texture = load("res://assets/player/Statue_Crumbled.png")
		#disable avoidance
