extends Node2D

@export var enemy : PackedScene
@export var totalEnemies = 0
@export var Spawner : Node = self
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
	for n in totalEnemies:
		if not Spawns.is_empty():
			var spawnMe = Spawns.pick_random()
			Spawns.erase(spawnMe)
			var enemyInst = enemy.instantiate()
			enemyInst.position = spawnMe.position
			#print("Spawning at " + str(spawnMe))
			add_child(enemyInst)
		else:
			return

func _remove_and_respawn():
	for isEnemy in get_children():
		if "isEnemy" in isEnemy:
			isEnemy.queue_free()
	_spawn()
