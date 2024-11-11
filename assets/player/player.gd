extends CharacterBody2D
## Character controller

@onready var collision: CollisionShape2D = $Collision
@onready var spawn: Marker2D = $"../Spawn"
@onready var statue: PackedScene = preload("res://assets/player/Statue.tscn")

var died = false
var Chalk = Line2D.new()

@export_category("Movement")
@export var speed : int = 60 ## Player max speed
@export var friction : float = 0.1 ## How fast player slows down when not moving
@export var acceleration : float = 0.1 ## How long it takes for player to reach full speed

@export_category("Upgrades")
@export var upgradeCHALK : bool = true ## false = Not Unlocked/Active [br]Draws line where player has been

func _ready():
	SignalBus.connect('playerHit', _player_hit)
	new_line()

func get_input():
	var input = Vector2()
	if Input.is_action_pressed('PLAYER_UP'):
		input.y -= 1
	if Input.is_action_pressed('PLAYER_DOWN'):
		input.y += 1
	if Input.is_action_pressed('PLAYER_LEFT'):
		input.x -= 1
	if Input.is_action_pressed('PLAYER_RIGHT'):
		input.x += 1
	if Input.is_action_pressed("SPRINT"):
		speed = 100
	else:
		speed = 60
	return input

func _physics_process(_delta):
	if died:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	else:
		var direction = get_input()
		if direction.length() > 0:
			velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		else:
			velocity = velocity.lerp(Vector2.ZERO, friction)
	if upgradeCHALK and not velocity == Vector2(0, 0) and not died:
		Chalk.add_point(position)
	move_and_slide()
	
func _player_hit():
	#For when player has been hit by enemy
	print("I've been hit!")
	died = true
	#process_mode = PROCESS_MODE_DISABLED
	new_line()
	#collision.disabled = true
	#self.name = "DeadPlayer" + str(randi())
	SignalBus.emit_signal('playerDied')
	#Play death animation
	await get_tree().create_timer(3.0).timeout
	var instance = statue.instantiate()
	instance.position = position
	get_parent().add_child(instance)
	position = spawn.position
	died = false
	#process_mode = PROCESS_MODE_INHERIT
	
func new_line():
	Chalk = Line2D.new()
	Chalk.width = 1
	Chalk.default_color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
	Chalk.z_index = -1
	get_parent().add_child(Chalk)
