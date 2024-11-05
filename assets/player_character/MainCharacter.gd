extends CharacterBody2D

@onready var playerSpriteNode: Sprite2D = $playerSprites
@onready var playerAnimationsNode: AnimationPlayer = $playerAnimations

@export var baseMoveSpeed: float = 100.0
@export var sprintScalar: float = 1.5
@export var characterAcceleration: float = 0.2
@export var playerLocked: bool = false
@export var sprintType = GlobalSettings.playerSprintType

var inputDirection: Vector2 = Vector2.ZERO
var directionState: DIRECTION_STATES = DIRECTION_STATES.IDLE_S
var runningState: bool = false
var previousMovingDirection: DIRECTION_STATES = DIRECTION_STATES.IDLE_S

signal playerIsLocked
signal playerIsUnlocked

enum DIRECTION_STATES {
	MOVING_N, MOVING_NE, MOVING_E, MOVING_SE, MOVING_S, MOVING_SW, MOVING_W, MOVING_NW,
	IDLE_N, IDLE_NE, IDLE_E, IDLE_SE, IDLE_S, IDLE_SW, IDLE_W, IDLE_NW
}

const MOVING_TO_IDLE = {
	DIRECTION_STATES.MOVING_N: DIRECTION_STATES.IDLE_N,
	DIRECTION_STATES.MOVING_NE: DIRECTION_STATES.IDLE_NE,
	DIRECTION_STATES.MOVING_E: DIRECTION_STATES.IDLE_E,
	DIRECTION_STATES.MOVING_SE: DIRECTION_STATES.IDLE_SE,
	DIRECTION_STATES.MOVING_S: DIRECTION_STATES.IDLE_S,
	DIRECTION_STATES.MOVING_SW: DIRECTION_STATES.IDLE_SW,
	DIRECTION_STATES.MOVING_W: DIRECTION_STATES.IDLE_W,
	DIRECTION_STATES.MOVING_NW: DIRECTION_STATES.IDLE_NW
}

func _ready():
	playerAnimationsNode.current_animation = "idle_east_normal"
	SignalBus.connect('playerHit', _player_hit)

func _input(_event: InputEvent):
	if playerLocked:
		return
	update_sprint()
	inputDirection = get_movement_input()
	update_state(inputDirection)

func get_movement_input() -> Vector2:
	# Retrieve player input and normalize for consistent diagonal speed
	var playerDirection = Vector2()
	if Input.is_action_pressed("player_move_east"):
		playerDirection.x += 1
	if Input.is_action_pressed("player_move_west"):
		playerDirection.x -= 1
	if Input.is_action_pressed("player_move_south"):
		playerDirection.y += 1
	if Input.is_action_pressed("player_move_north"):
		playerDirection.y -= 1
	return playerDirection.normalized()

func update_state(playerDirection: Vector2):
	# Determine movement or idle state based on player input
	directionState = get_direction_state(playerDirection)
	if playerDirection == Vector2.ZERO:
		# Set to idle if not moving
		directionState = MOVING_TO_IDLE.get(previousMovingDirection, DIRECTION_STATES.IDLE_S)
	else:
		# Update last moving direction if in motion
		previousMovingDirection = directionState
	play_animation()

func get_direction_state(playerDirection: Vector2) -> DIRECTION_STATES:
	# Helper function to determine directional state based on input vector
	if abs(playerDirection.x) > 0.5 and abs(playerDirection.y) > 0.5:
		if playerDirection.x > 0 and playerDirection.y > 0:
			return DIRECTION_STATES.MOVING_SE
		elif playerDirection.x > 0 and playerDirection.y < 0:
			return DIRECTION_STATES.MOVING_NE
		elif playerDirection.x < 0 and playerDirection.y > 0:
			return DIRECTION_STATES.MOVING_SW
		elif playerDirection.x < 0 and playerDirection.y < 0:
			return DIRECTION_STATES.MOVING_NW
	elif playerDirection.x > 0:
		return DIRECTION_STATES.MOVING_E
	elif playerDirection.x < 0:
		return DIRECTION_STATES.MOVING_W
	elif playerDirection.y > 0:
		return DIRECTION_STATES.MOVING_S
	elif playerDirection.y < 0:
		return DIRECTION_STATES.MOVING_N
	return DIRECTION_STATES.IDLE_S

func play_animation():
	# Play corresponding animation based on direction and running state
	var currentAnimationPosition = playerAnimationsNode.current_animation_position
	playerAnimationsNode.set_speed_scale(2.0 if runningState else 1.0)

	match directionState:
		DIRECTION_STATES.MOVING_N:
			playerAnimationsNode.play("run_north_normal" if runningState else "walk_north_normal")
		DIRECTION_STATES.MOVING_S:
			playerAnimationsNode.play("run_south_normal" if runningState else "walk_south_normal")
		DIRECTION_STATES.MOVING_E:
			playerAnimationsNode.play("run_east_normal" if runningState else "walk_east_normal")
		DIRECTION_STATES.MOVING_W:
			playerAnimationsNode.play("run_west_normal" if runningState else "walk_west_normal")
		DIRECTION_STATES.MOVING_NE:
			playerAnimationsNode.play("run_north_east_normal" if runningState else "walk_north_east_normal")
		DIRECTION_STATES.MOVING_SE:
			playerAnimationsNode.play("run_south_east_normal" if runningState else "walk_south_east_normal")
		DIRECTION_STATES.MOVING_NW:
			playerAnimationsNode.play("run_north_west_normal" if runningState else "walk_north_west_normal")
		DIRECTION_STATES.MOVING_SW:
			playerAnimationsNode.play("run_south_west_normal" if runningState else "walk_south_west_normal")

		# Idle animations
		DIRECTION_STATES.IDLE_N: playerAnimationsNode.play("idle_north_normal")
		DIRECTION_STATES.IDLE_S: playerAnimationsNode.play("idle_south_normal")
		DIRECTION_STATES.IDLE_E: playerAnimationsNode.play("idle_east_normal")
		DIRECTION_STATES.IDLE_W: playerAnimationsNode.play("idle_west_normal")
		DIRECTION_STATES.IDLE_NE: playerAnimationsNode.play("idle_north_east_normal")
		DIRECTION_STATES.IDLE_SE: playerAnimationsNode.play("idle_south_east_normal")
		DIRECTION_STATES.IDLE_NW: playerAnimationsNode.play("idle_north_west_normal")
		DIRECTION_STATES.IDLE_SW: playerAnimationsNode.play("idle_south_west_normal")

	playerAnimationsNode.seek(currentAnimationPosition)

func update_sprint():
	# Handle sprint toggle or hold based on sprintType
	if sprintType == GlobalSettings.SPRINT_TYPES.TOGGLE:  # Toggle mode
		if Input.is_action_just_released("player_toggle_sprint"):
			runningState = !runningState
	else:  # Hold mode
		runningState = Input.is_action_pressed("player_toggle_sprint")

func lock_player():
	playerLocked = true
	emit_signal("playerIsLocked")

func unlock_player():
	playerLocked = false
	emit_signal("playerIsUnlocked")
	
func _player_hit():
	#For when player has been hit by enemy
	print("I've been hit!")
	$Label.visible = true
	await get_tree().create_timer(1.0).timeout
	$Label.visible = false

func _physics_process(_delta: float) -> void:
	# Calculate target velocity based on direction and sprinting?
	var target_velocity = inputDirection * baseMoveSpeed * (sprintScalar if runningState else 1.0)
	velocity = velocity.lerp(target_velocity, characterAcceleration)
	move_and_slide()
