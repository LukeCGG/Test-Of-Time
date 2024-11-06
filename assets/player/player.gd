extends CharacterBody2D

@export var speed = 60
@export var friction = 0.1
@export var acceleration = 0.1

func _ready():
	SignalBus.connect('playerHit', _player_hit)

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
	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	move_and_slide()
	
func _player_hit():
	#For when player has been hit by enemy
	print("I've been hit!")
	$Label.visible = true
	await get_tree().create_timer(1.0).timeout
	$Label.visible = false
