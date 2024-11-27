extends CharacterBody2D
## Character controller

@onready var collision: CollisionShape2D = $Collision
@onready var spawn: Marker2D = $"../Spawn"
@onready var statue: PackedScene = preload("res://assets/player/Statue.tscn")
@onready var sprites: AnimatedSprite2D = $Sprites
const INVENTORY_UI = preload("res://assets/menus_and_ui/InventoryUI.tscn")
const ACC_INV_UI = preload("res://assets/menus_and_ui/AccessInventoryUI.tscn")
const PLAYER_INVENTORY = preload("res://assets/player/player_inventory.tres")
const ACC_INV = preload("res://assets/levels/access_inventory.tres")
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var health_loss: Label = $"HealthLoss"
@onready var interaction_area: Area2D = $InteractionArea

@onready var walls_shadows: PointLight2D = $WallsShadows
@onready var window_shadows: PointLight2D = $WindowShadows

var died = false
var Chalk = Line2D.new()
var SelectedInv = null
var Invinci = false
var fullBright = true

@export var maxHealth : int = 100
var health : int = maxHealth
@export_category("Movement")
@export var walkSpeed : int = 60 ## Player max walk speed
@export var runSpeed : int = 100 ## Player max run speed
@export var friction : float = 0.1 ## How fast player slows down when not moving
@export var acceleration : float = 0.1 ## How long it takes for player to reach full speed
var speed = walkSpeed

@export_category("Upgrades") ## false = Not Unlocked/Active 
var upgradeCHALK : bool = false ## Draws line where player has been
var upgradeVISION : bool = false ## Further viewing distance
var upgradeSPEED : bool = false ## Increases movement speed
var SpeedBoost : int = 40 # How much speed is added when upgrade is applied

func _ready():
	SignalBus.connect('playerHit', _player_hit)
	_check_upgrades()
		
func _check_upgrades():
	upgradeCHALK = false
	upgradeVISION = false
	upgradeSPEED = false
	for i in PLAYER_INVENTORY.items:
		if i != null:
			if i.name == "Chalk":
				upgradeCHALK = true
			if i.name == "Lantern":
				upgradeVISION = true
			if i.name == "Light Boots":
				upgradeSPEED = true

	if upgradeCHALK:
		new_line()
	else:
		Chalk = Line2D.new()
	if upgradeVISION:
		walls_shadows.texture_scale = 0.45
		window_shadows.texture_scale = 0.45
	else:
		walls_shadows.texture_scale = 0.25
		window_shadows.texture_scale = 0.25
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("INVENTORY") and not died:
		if has_node("/root/InventoryUI") or has_node("/root/AccessInventoryUI"):
			return
		else:
			if SelectedInv != null:
				if "Item" in SelectedInv:
					var filled = false
					for slot in PLAYER_INVENTORY.items.size():
						var item = PLAYER_INVENTORY.items[slot]
						if item == null and filled == false:
							PLAYER_INVENTORY.items.remove_at(slot)
							PLAYER_INVENTORY.items.insert(slot, SelectedInv.type)
							filled = true
							SelectedInv._removal()
							return
					if filled == false:
						print("No space")
						health_loss.text = "No Space"
						animation.play("HealthLoss")
						var inventory = ACC_INV_UI.instantiate()
						get_tree().root.add_child(inventory)
				else:
					#print("enable inv access")
					var inventory = ACC_INV_UI.instantiate()
					get_tree().root.add_child(inventory)
			else:
				#print("enable inv player")
				var inventory = INVENTORY_UI.instantiate()
				get_tree().root.add_child(inventory)

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
		
	return input

func _physics_process(delta: float) -> void:
	if died:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	else:
		var direction = get_input()
		if direction.length() > 0:
			if upgradeSPEED:
				if Input.is_action_pressed("SPRINT"):
					speed = 100 + SpeedBoost
					sprites.play('run')
				else:
					speed = 60 + SpeedBoost
					sprites.play('walk')
			else:
				if Input.is_action_pressed("SPRINT"):
					speed = 100
					sprites.play('run')
				else:
					speed = 60
					sprites.play('walk')
			velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		else:
			velocity = velocity.lerp(Vector2.ZERO, friction)
			sprites.play('idle')
			
	if not $InvinciTimer.is_stopped():
		if fullBright == true:
			sprites.modulate = lerp(sprites.modulate,Color(1,1,1,0), 10 * delta)
			if sprites.modulate.a <= 0.2:
				fullBright = false
		else:
			sprites.modulate = lerp(sprites.modulate,Color(1,1,1,1), 10 * delta)
			if sprites.modulate.a >= 0.8:
				fullBright = true
			
	if upgradeCHALK == true and not velocity.length() <= 3 and not died:
		Chalk.add_point(Vector2(position.x + 3, position.y - 2))
		#Chalk.texture.set('width', Chalk.texture.get_width()+15)
	move_and_slide()
	
func _player_hit(damage):
	#For when player has been hit by enemy
	#print("I've been hit! " + str(health) + " -" + str(damage))
	#Lose Health
	if not Invinci:
		Invinci = true
		$CPUParticles2D.emitting = true
		$InvinciTimer.start()
		health_loss.text = "-"+str(damage)
		animation.play("HealthLoss")
		health -= damage
		if health <= 0:
			health = 0
			_player_died()
	
func _player_died():
	died = true
	SignalBus.emit_signal('playerDied')
	#Play death animation
	sprites.play('statue')
	await get_tree().create_timer(3.0).timeout
	var instance = statue.instantiate()
	instance.InvInst = Inventory.new()
	for item in PLAYER_INVENTORY.items:
		instance.InvInst.items.append(item)
	PLAYER_INVENTORY.items.clear()
	for i in range(16):
		PLAYER_INVENTORY.items.append(null)
	instance.position = position
	get_parent().add_child(instance)
	position = spawn.position
	SignalBus.emit_signal('newGeneration')
	died = false
	_check_upgrades()
	health = 100
	sprites.play('idle')
	
func new_line():
	Chalk = Line2D.new()
	Chalk.set_script(preload("res://assets/player/chalk_line.gd"))
	Chalk.width = 3
	Chalk.z_index = -1
	#Chalk.default_color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
	Chalk.default_color = Color(1,1,1,0.70)
	Chalk.texture = preload("res://assets/player/ChalkNoise.tres")
	Chalk.texture_mode = Line2D.LINE_TEXTURE_TILE
	Chalk.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	Chalk.z_index = -1
	get_parent().add_child(Chalk)

func _on_interaction_area_body_entered(_bodys: Node2D) -> void:
	if SelectedInv == null:
		for body in interaction_area.get_overlapping_bodies():
			if "Interactable" in body:
				var StatSprite = body.get_child(0)
				if StatSprite.material.get("shader_parameter/color") == Color(1,1,1,0):
					SelectedInv = StatSprite
					StatSprite.material.set("shader_parameter/color", Color(1,1,1,1))
				ACC_INV.items.clear()
				for i in body.InvInst.items:
					ACC_INV.items.append(i)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if SelectedInv != null and "Interactable" in body:
		var stillIn : bool = false
		for bodies in interaction_area.get_overlapping_bodies():
			if bodies.get_child_count() > 0:
				if bodies.get_child(0) == SelectedInv:
					stillIn = true
		if stillIn == false:
			SelectedInv.material.set("shader_parameter/color", Color(1,1,1,0))
			SelectedInv = null
			_on_interaction_area_body_entered(null)
			body.InvInst.items.clear()
			for i in ACC_INV.items:
				body.InvInst.items.append(i)
			ACC_INV.items.clear()
	if "Interactable" in body:
		if body.get_child(0).material.get("shader_parameter/color") == Color(1,1,1,1):
			body.get_child(0).material.set("shader_parameter/color", Color(1,1,1,0))

func _on_interaction_area_area_entered(_areas: Area2D) -> void:
	if SelectedInv == null:
		for area in interaction_area.get_overlapping_areas():
			if "Item" in area:
				var StatSprite = area.get_child(0)
				if StatSprite.material.get("shader_parameter/color") == Color(1,1,1,0):
					SelectedInv = area
					StatSprite.material.set("shader_parameter/color", Color(1,1,1,1))
			if "Interactable" in area:
				var StatSprite = area.get_child(0)
				if StatSprite.material.get("shader_parameter/color") == Color(1,1,1,0):
					SelectedInv = StatSprite
					StatSprite.material.set("shader_parameter/color", Color(1,1,1,1))
				ACC_INV.items.clear()
				for i in area.InvInst.items:
					ACC_INV.items.append(i)

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if SelectedInv != null and ("Item" in area or "Interactable" in area):
		var stillIn : bool = false
		for areas in interaction_area.get_overlapping_areas():
			if areas.get_child_count() > 0:
				if areas.get_child(0) == SelectedInv:
					stillIn = true
		if stillIn == false:
			if "Interactable" in SelectedInv.get_parent():
				SelectedInv.material.set("shader_parameter/color", Color(1,1,1,0))
				SelectedInv = null
				_on_interaction_area_area_entered(null)
				area.InvInst.items.clear()
				for i in ACC_INV.items:
					area.InvInst.items.append(i)
				ACC_INV.items.clear()
			else:
				SelectedInv.get_child(0).material.set("shader_parameter/color", Color(1,1,1,0))
				SelectedInv = null
				_on_interaction_area_area_entered(null)
	if "Item" in area or "Interactable" in area:
		if area.get_child(0).material.get("shader_parameter/color") == Color(1,1,1,1):
			area.get_child(0).material.set("shader_parameter/color", Color(1,1,1,0))

func _on_invinci_timer_timeout() -> void:
	Invinci = false
	sprites.modulate = Color(1,1,1,1)
	fullBright = true
