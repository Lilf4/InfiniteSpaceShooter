extends Node3D

@onready var enemeyScene = preload("res://enemy.tscn")

@onready var main = find_parent("Main")
@onready var player = find_parent("Main").find_child("Player")

@export var radius = 500
@export var enemies = 10

@export var maxEnemiesAlive = 5
@export var minEnemiesKilledToSpawn = 4

var enemiesSpawned = 0
var enemiesAlive = 0
var enemiesLeft = 0
var enemiesKilledSinceSpawn = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	enemiesLeft = enemies
	enemiesKilledSinceSpawn = minEnemiesKilledToSpawn
	trySpawnEnemies()

func spawnEnemies(count):
	for i in range(count):
		var points = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5)
		points = points.normalized()
		var newEnemy = enemeyScene.instantiate()
		newEnemy.set_position((points * radius) + player.position)
		newEnemy.connect("enemyDeath", enemyDied)
		main.add_child.call_deferred(newEnemy)
		enemiesAlive += 1

func enemyDied():
	enemiesAlive -= 1
	enemiesKilledSinceSpawn += 1


func _on_spawn_timer_timeout():
	trySpawnEnemies()

func trySpawnEnemies():
	#Try to spawn enemies
	if enemiesLeft > 0 and enemiesAlive < maxEnemiesAlive and enemiesKilledSinceSpawn >= minEnemiesKilledToSpawn:
		var enemiesToSpawn = enemiesLeft if (maxEnemiesAlive - enemiesAlive) > enemiesLeft else (maxEnemiesAlive - enemiesAlive)
		spawnEnemies(enemiesToSpawn)
		enemiesSpawned += enemiesToSpawn
		enemiesLeft -= enemiesToSpawn
		enemiesKilledSinceSpawn = 0
	print("Enemies spawned: ", enemiesSpawned, "\r\nEnemies alive: ", enemiesAlive, "\r\nEnemies left: ", enemiesLeft)