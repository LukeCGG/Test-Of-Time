extends Area2D

@export var damage : int = 10
var SpikesUp = false

@onready var hit: Area2D = $Hit
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	pass

func _on_area_entered(body: Node2D) -> void:
	if body.name == "Player":
		$CollisionShape2D.call_deferred("set_disabled", true)
		await get_tree().create_timer(0.2).timeout
		sprite_2d.frame = 1
		SpikesUp = true
		for bodies in hit.get_overlapping_bodies():
			if bodies.name == "Player":
				SignalBus.playerHit.emit(damage)
				break
		collision_shape_2d.disabled = false
		$Cooldown.start()

func _on_cooldown_timeout() -> void:
	if SpikesUp:
		sprite_2d.frame = 0
		collision_shape_2d.disabled = true
		SpikesUp = false
		$Cooldown.start()
	else:
		$CollisionShape2D.disabled = false
		
