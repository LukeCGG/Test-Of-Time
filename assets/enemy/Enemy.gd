extends CharacterBody2D

@export var speed : int = 50
var accel = 5
var speeder = speed
@export var wanderDistance : int = 200
@onready var playerBody = $"../Player"
var hitting = false

@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Sprite
@onready var detection_zone: Area2D = $DetectionZone
@onready var cast: RayCast2D = $Cast
@onready var hit_detection: Area2D = $HitDetection

func _ready() -> void:
	#set_physics_process(false)
	#Go in a direction
	makepath()

func _physics_process(delta: float) -> void:
	var direction = to_local(nav.get_next_path_position()).normalized()
	
	velocity = velocity.lerp(direction * speeder, accel * delta)
		
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
	elif direction.x > 0:
		animated_sprite_2d.flip_h = false
			
	if nav.is_navigation_finished() and not hitting:
		animated_sprite_2d.play('idle')
		nav.target_position = position
		velocity = Vector2(0,0)
	elif not hitting:
		animated_sprite_2d.play('move')
	
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
	cast.target_position = playerBody.global_position - self.position
	cast.force_raycast_update()
	if not cast.is_colliding():
		$WanderTimer.stop()
		nav.target_position = playerBody.position
	elif $WanderTimer.is_stopped():
		$WanderTimer.start()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _on_hit_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if $HitTimer.is_stopped() and $HitTimer/CooldownTimer.is_stopped():
			hitting = true
			speeder = 0
			animated_sprite_2d.play('hit')
			$HitTimer.start()
		else:
			speeder = speed
		if speeder == 500:
			#print("I hit the player!")
			SignalBus.emit_signal('playerHit')
			hitting = false

func _on_hit_timer_timeout() -> void:
	$HitTimer/CooldownTimer.start()
	#print("attempting hit!")
	for body in hit_detection.get_overlapping_bodies():
		if body.name == "Player":
			speeder = speed
			#print("I hit the player!")
			SignalBus.emit_signal('playerHit')
			hitting = false
			return
	nav.target_position = playerBody.position
	speeder = 1000
	await get_tree().create_timer(0.3).timeout
	_check_hit()
	speeder = speed
	await get_tree().create_timer(0.1).timeout
	hitting = false
	
func _on_cooldown_timer_timeout() -> void:
	for body in hit_detection.get_overlapping_bodies():
		if body.name == "Player":
			_on_hit_detection_body_entered(body)
			
func _check_hit():
	for body in hit_detection.get_overlapping_bodies():
		if body.name == "Player" and hitting:
			#print("I hit the player!")
			SignalBus.emit_signal('playerHit')
