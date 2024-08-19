extends Node3D

# Concept - WaveSpawner will act as a type of director,-
# trying to give the player an exciting game.
#
# Takes a list of enemies, which contains spawn costs and weigths.
#
# Over the course of the game the director will track player performance,-
# wich it can use to either artificially increase/decrease the difficulty level-
# to some extend, which should also reward players more for better gameplay.
#
# Player performance will be measured on damage taken, enemies killed,- 
# time to kill, etc..
#
# At the start of each round the director gets a dynamic budget, 
# which it can spend on spawning enemies, this budget would be based on player-
# performance so increased or decreased upto a certain point.
# 
# Director will pick at start of wave whether to be cheap, and try and preserve
# the budget till later to test how the player will do
#
# Will spawn the enemies in a kind of mini waves which can be done in two ways,
# it can choose to spawn it's mini wave as one big pulse of enemies or a steady- 
# stream.

#List of enemies and their costs/weights/variants
@export var enemies: Array[Resource]

@onready var main = find_parent("Main")
@onready var player = find_parent("Main").find_child("Player")
@onready var WaveUI = main.find_child("WaveUI")

var score: float = 0

@export var DifficultyScalePower: float = 0.05

@export var spawnRadius: float = 500

@export_category("Enemy values")

var enemyAliveAmount: int = 0
var enemyAliveMult: float = 0
@export var enemyBaseMaxAliveMult: float = 0.2
@export var enemyMaxAliveMult: float = 0.45 

@export var enabled: bool = false

var enemiesSpawned: int = 0
var maxEnemiesAlive: int = 0
var enemiesAlive: int = 0
var enemiesLeft: int = 0

var waveOngoing: bool = false
var CurrentWave: int = 0
var CurrBaseDifficulty: float = 1.0
var CurrDifficultyOffset: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not enabled:
		return
	CurrentWave += 1
	WaveUI.SetWaveCount(CurrentWave)
	WaveUI.StartWave(5)

func _process(delta):
	pass

signal enemySpawned
func spawnEnemies(count):
	for i in range(count):
		var points = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5)
		points = points.normalized()
		#var newEnemy = enemeyScene.instantiate()
		#newEnemy.set_position((points * spawnRadius) + player.position)
		#newEnemy.connect("enemyDeath", enemyDied)
		
		#newEnemy.ID = System_Global.GET_NEWID()
		#newEnemy.Difficulty = CurrentDifficultyValue
		
		#System_Global.EnemyInstances[newEnemy.ID] = newEnemy
		#main.add_child.call_deferred(newEnemy)
		#enemySpawned.emit(newEnemy.ID)
		#enemiesAlive += 1

signal enemyDead
func enemyDied(id):
	if not enabled:
		return
	if(System_Global.EnemyInstances.erase(id)):
		enemyDead.emit(id)
		enemiesAlive -= 1
		#enemiesKilledSinceSpawn += 1
		score += CurrBaseDifficulty + CurrDifficultyOffset
		if enemiesAlive <= 0 and enemiesLeft <= 0:
			WaveDone()
			player.currHealth = clamp(player.currHealth + player.Health * (System_Global.baseEndRepair * System_Global.endRepairMultiplier) * 0.01, 0, player.Health)

func WaveDone():
	waveOngoing = false
	main.OpenUpgrades()

func StartNewWave():
	CurrentWave += 1
	WaveUI.SetWaveCount(CurrentWave)
	WaveUI.StartWave(5)
	pass


func trySpawnEnemies():
	#Try to spawn enemies
	#spawnEnemies(enemiesToSpawn)
	pass

#Setting up and starting new wave
func _on_wave_ui_wave_started():
	CurrBaseDifficulty = 1.0 + (CurrentWave - 1) * DifficultyScalePower
	waveOngoing = true
	
	trySpawnEnemies()


func _on_upgrade_menu_done_pressed():
	main.CloseUpgrades()
	StartNewWave()
