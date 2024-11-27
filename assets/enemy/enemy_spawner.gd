extends Node2D

@export var types : Array[PackedScene] ## Enemy Scenes for spawning
@export_group("Advanced Options")
@export var totalEnemies = 0 ## If you want less than total spawn locations
@export var Spawner : Node = self ## Parent of children Marker2Ds - Default 'self'
var Spawns : Array = []

func _ready() -> void:
	SignalBus.connect('newGeneration', _remove_and_respawn)
	_spawn()
		
func _spawn():
	Spawns.clear()
	for enemySpawn in Spawner.get_children():
		if enemySpawn.get_class() == "Marker2D":
			#print(enemySpawn)
			Spawns.append(enemySpawn)
	var enemy
	var prevEnm
	for n in totalEnemies:
		if not Spawns.is_empty():
			@warning_ignore("unassigned_variable") while enemy == prevEnm:
				enemy = types.pick_random()
			prevEnm = enemy
			var spawnMe = Spawns.pick_random()
			Spawns.erase(spawnMe)
			var enemyInst = enemy.instantiate()
			enemyInst.position = spawnMe.position
			#print("Spawning at " + str(spawnMe))
			add_child(enemyInst)
		else:
			break

func _remove_and_respawn():
	for isEnemy in get_children():
		if "isEnemy" in isEnemy:
			isEnemy.queue_free()
	_spawn()
