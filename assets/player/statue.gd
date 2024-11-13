extends StaticBody2D

var lifecycle : int = 3 + 1 #Lives plus 1 for initial death
@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $Collision

func _ready() -> void:
	SignalBus.connect('newGeneration', _age_statue)

func _age_statue():
	lifecycle -= 1
	#age statue
	if lifecycle <= 0:
		collision.disabled = true
		sprite.flip_v = true #crumbled statue
		#disable avoidance
