extends CharacterBody2D
## Enemy AI

var isEnemy : bool = true ## Identified as an Enemy

@export var speed : int = 30
var accel = 5
var speeder = speed
@export var wanderDistance : int = 200
@export var damage : int = 50
var playerBody
var hitting = false

@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Sprite
@onready var detection_zone: Area2D = $DetectionZone
@onready var cast: RayCast2D = $Cast
@onready var hit_detection: Area2D = $HitDetection

func _ready() -> void:
	#set_physics_process(false)
	makepath.call_deferred()
	SignalBus.connect('playerDied', _player_died)
	SignalBus.connect('playerHit', _player_hit)

func _physics_process(delta: float) -> void:
	await get_tree().physics_frame
	var direction = to_local(nav.get_next_path_position()).normalized()
	
	var intended_velocity = velocity.lerp(direction * speeder, accel * delta)
	nav.set_velocity(intended_velocity)
		
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
	elif direction.x > 0:
		animated_sprite_2d.flip_h = false
			
	if nav.is_navigation_finished() and not hitting:
		animated_sprite_2d.play('idle')
		nav.target_position = position
		velocity = Vector2(0,0)
		return
	elif not hitting:
		if not $ChaseTimer.is_stopped():
			animated_sprite_2d.play('run')
		else:
			animated_sprite_2d.play('walk')
	
	move_and_slide()
	
func makepath():
	#Random direciton withing 100 pixels radius
	nav.target_position = Vector2(position.x + randi_range(-wanderDistance, wanderDistance), position.y + randi_range(-wanderDistance, wanderDistance))
	$WanderTimer.start()

func _on_timer_timeout() -> void:
	#Go in a direciton after timer finishes
	$WanderTimer.wait_time = randi_range(3, 10)
	makepath()

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		playerBody = body
		$ChaseTimer.start()

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		#print("Lost Sight")
		$ChaseTimer.stop()
		$WanderTimer.wait_time = 10
		$WanderTimer.start()

func _on_chase_timer_timeout() -> void:
	cast.target_position = Vector2(playerBody.global_position.x - self.position.x, playerBody.global_position.y - self.position.y - 16)
	cast.force_raycast_update()
	if not cast.is_colliding():
		$WanderTimer.stop()
		nav.target_position = Vector2(playerBody.position.x, playerBody.position.y - 16)
	elif $WanderTimer.is_stopped():
		$WanderTimer.start()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _on_hit_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if $HitTimer.is_stopped() and $HitTimer/CooldownTimer.is_stopped():
			hitting = true
			speeder = 0
			animated_sprite_2d.play('hit')
			$HitTimer.start()
		else:
			speeder = speed
		if speeder == 250:
			#print("I hit the player!")
			SignalBus.playerHit.emit(damage)
			hitting = false

func _on_hit_timer_timeout() -> void:
	$HitTimer/CooldownTimer.start()
	#print("attempting hit!")
	for body in hit_detection.get_overlapping_bodies():
		if body.name == "Player":
			speeder = speed
			#print("I hit the player!")
			SignalBus.playerHit.emit(damage)
			hitting = false
			return
	nav.target_position = Vector2(playerBody.position.x, playerBody.position.y - 16)
	speeder = 1000
	await get_tree().create_timer(0.3).timeout
	_check_hit()
	speeder = speed
	await get_tree().create_timer(0.1).timeout
	hitting = false
	
func _on_cooldown_timer_timeout() -> void:
	if $DetectionZone.monitoring == true:
		for body in hit_detection.get_overlapping_bodies():
			if body.name == "Player":
				_on_hit_detection_body_entered(body)
			
func _check_hit():
	for body in hit_detection.get_overlapping_bodies():
		if body.name == "Player" and hitting:
			#print("I hit the player!")
			SignalBus.playerHit.emit(damage)

func _player_died():
	$ChaseTimer.stop()
	$DetectionZone.monitoring = false
	$HitDetection.monitoring = false
	await get_tree().create_timer(4).timeout
	$DetectionZone.monitoring = true
	$HitDetection.monitoring = true
	$WanderTimer.start()
	
func _player_hit(_damage):
	pass
