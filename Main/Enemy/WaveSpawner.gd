extends Node3D

#Concept
#Enemies will spawn in waves which will progressively become longer/harder
#Difficulty will be decided by amount of enemies to kill.
#Aswell as a speedup in enemy movement-
#and tighter/looser enemy acccuracy threshold

@onready var enemeyScene = preload("res://Main/Enemy/enemy.tscn")

@onready var main = find_parent("Main")
@onready var player = find_parent("Main").find_child("Player")
@onready var WaveUI = main.find_child("WaveUI")

var score: float = 0

@export var DifficultyScalePower: float = 0.05

@export var spawnRadius: float = 500

@export_category("Enemy values")
var enemyCount: int = 0
@export var enemyBaseCount: int = 10

var enemySpawnAmount: int = 0
@export var enemyBaseSpawnAmount: int = 2
@export var enemyMaxSpawnAmount: int = 5

var enemyAliveAmount: int = 0
var enemyAliveMult: float = 0
@export var enemyBaseMaxAliveMult: float = 0.2
@export var enemyMaxAliveMult: float = 0.45 

var enemyKillBeforeSpawn: int = 0
var enemyKillBeforeSpawnMult: float = 0
@export var enemyBaseKillBeforeSpawnMult: float = 1.0

@export var enemyBaseSpeed: float = 50
var speedMultiplier: float = 0
@export var enemyBaseSpeedMultiplier: float = 1
@export var enemyMaxSpeedMultiplier: float = 1.5

@export var enemyBaseAccuracy: float = 0.002
@export var enemyMinAccuracyValue: float = 0.001
@export var enemyMaxAccuracyValue: float = 0.003

@export var enemyFireRate: float = 0.5
@export var enemyMinFireRate: float = 0.2

@export var enabled: bool = true

var enemiesSpawned: int = 0
var maxEnemiesAlive: int = 0
var enemiesAlive: int = 0
var enemiesLeft: int = 0
var enemiesToKillBeforeSpawn: int = 0 
var enemiesKilledSinceSpawn: int = 0
var CurrentWave: int = 0
var CurrentDifficultyValue: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not enabled:
		return
	CurrentWave += 1
	WaveUI.SetWaveCount(CurrentWave)
	WaveUI.StartWave(5)

signal enemySpawned
func spawnEnemies(count):
	for i in range(count):
		var points = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5)
		points = points.normalized()
		var newEnemy = enemeyScene.instantiate()
		newEnemy.set_position((points * spawnRadius) + player.position)
		newEnemy.connect("enemyDeath", enemyDied)
		newEnemy.ID = System_Global.GET_NEWID()
		newEnemy.FireRate = clamp(enemyFireRate - (CurrentDifficultyValue - 1.0) * enemyFireRate, enemyMinFireRate, enemyFireRate)
		newEnemy.accuracyDist = clamp(enemyFireRate - (CurrentDifficultyValue - 1.0) * enemyFireRate, enemyMinFireRate, enemyFireRate)
		speedMultiplier = clamp(enemyBaseSpeedMultiplier + (CurrentDifficultyValue - 1.0) * enemyBaseSpeedMultiplier, enemyBaseSpeedMultiplier, enemyMaxSpeedMultiplier)
		var maxSpeed = enemyBaseSpeed * speedMultiplier
		newEnemy.MaxSpeed = Vector3(maxSpeed, maxSpeed, maxSpeed)
		System_Global.EnemyInstances[newEnemy.ID] = newEnemy
		main.add_child.call_deferred(newEnemy)
		enemySpawned.emit(newEnemy.ID)
		enemiesAlive += 1

signal enemyDead
func enemyDied(id):
	if not enabled:
		return
	if(System_Global.EnemyInstances.erase(id)):
		enemyDead.emit(id)
		enemiesAlive -= 1
		enemiesKilledSinceSpawn += 1
		score += CurrentDifficultyValue
		if enemiesAlive <= 0 and enemiesLeft <= 0:
			#Wave is done
			player.currHealth = clamp(player.currHealth + player.Health * 0.25, 0, player.Health)
			

func WaveDone():
	pass

func StartNewWave():
	CurrentWave += 1
	WaveUI.SetWaveCount(CurrentWave)
	WaveUI.StartWave(5)
	pass


func _on_spawn_timer_timeout():
	trySpawnEnemies()

func trySpawnEnemies():
	#Try to spawn enemies
	if enemiesLeft > 0 and enemiesAlive < maxEnemiesAlive and enemiesKilledSinceSpawn >= enemyKillBeforeSpawn:
		var enemiesToSpawn = enemiesLeft if enemySpawnAmount - enemiesAlive >= enemiesLeft else enemySpawnAmount if  maxEnemiesAlive - enemiesAlive >= enemySpawnAmount else maxEnemiesAlive - enemySpawnAmount
		print(
			str("Trying to spawn, Info\r\n"),
			str("Enemies Left: ", enemiesLeft, "\r\n"), 
			str("Enemies Alive: ", enemiesAlive, "\r\n"),
			str("Maximum Alive Enemies Allowed: ", maxEnemiesAlive, "\r\n"), 
			str("Enemies Killed Since Last Spawn Attempt: ", enemiesKilledSinceSpawn, "\r\n"), 
			str("Enemies Left To Kill Before Spawn Is Allowed: ", enemyKillBeforeSpawn, "\r\n"), 
			str("Enemies Left To Spawn: ", enemiesToSpawn, "\r\n"), 
			str("Max Spawn Amount Per Try: ", enemySpawnAmount, "\r\n")
		)
		spawnEnemies(enemiesToSpawn)
		enemiesSpawned += enemiesToSpawn
		enemiesLeft -= enemiesToSpawn
		enemiesKilledSinceSpawn = 0

#Setup necessary values and call functions for starting a wave
func _on_wave_ui_wave_started():
	CurrentDifficultyValue = 1.0 + (CurrentWave - 1) * DifficultyScalePower
	
	enemyCount = enemyBaseCount * CurrentDifficultyValue
	enemyAliveMult = clamp(enemyBaseMaxAliveMult + (enemyBaseMaxAliveMult * CurrentDifficultyValue), enemyBaseMaxAliveMult, enemyMaxAliveMult)
	maxEnemiesAlive = enemyCount * enemyAliveMult
	
	enemySpawnAmount = clamp(enemyBaseSpawnAmount + (enemyBaseSpawnAmount * CurrentDifficultyValue), enemyBaseSpawnAmount, enemyMaxSpawnAmount)
	
	enemyKillBeforeSpawnMult = clamp(enemyBaseKillBeforeSpawnMult - (CurrentDifficultyValue - 1.0) * enemyBaseKillBeforeSpawnMult, 0, enemyBaseKillBeforeSpawnMult)
	enemiesToKillBeforeSpawn = enemyCount * enemyKillBeforeSpawnMult
	
	enemiesLeft = enemyCount
	
	trySpawnEnemies()
