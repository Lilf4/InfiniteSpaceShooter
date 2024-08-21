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
# Director will pick at start of wave whether to fx. be cheap, and try and preserve
# the budget till later to test how the player will do
#
# Will spawn the enemies in a kind of mini waves which can be done in two ways,
# it can choose to spawn it's mini wave as one big pulse of enemies or a steady- 
# stream.

#List of enemies and their costs/weights/variants
@export var enemies: Array[EnemySpawnDescriptor]

@onready var main = find_parent("Main")
@onready var player = find_parent("Main").find_child("Player")
@onready var WaveUI = main.find_child("WaveUI")

@export var enabled: bool = false

var score: float = 0

@export var spawnRadius: float = 500

var playerPerformance: float = 1

var enemiesSpawned: int = 0
var maxEnemiesAlive: int = 0
var enemiesAlive: int = 0

var spawningDataDecided: bool = false
var spawningMiniWave: bool = false
var miniWaveOngoing: bool = false
var waveStarted: bool = false
var waveOngoing: bool = false
var CurrentWave: int = 0
var timeTillNextMini: float = 0
var timeRangeForMini: Vector2 = Vector2(3, 6)
@export var DifficultyScalePower: float = 0.05
var CurrBaseDifficulty: float = 1.0
var CurrDifficultyOffset: float = 0.0

var BaseBudget: int = 300
var CurrBaseBudget: int = 300
var CurrBudget: int = 300

enum spawnBiases {
	Weak,
	
}

var currBudgetOption: BudgetOptions
enum BudgetOptions {
	Observer,
	BigSpender
}

var currSpawnMode: SpawnModes
enum SpawnModes {
	Pulse,
	Rapid
}

func _ready():
	if not enabled:
		return
	CurrentWave += 1
	connect("enemyDead", System_Global.playerKilled)
	WaveUI.SetWaveCount(CurrentWave)
	WaveUI.StartWave(5)

## Todo: 
## Player Performance
## Budget Handling
func _process(delta):
	if enemiesAlive <= 0 and getValidEnemies(CurrBudget).size() == 0 and waveOngoing:
		WaveDone()
		var healthToAdd: float = player.Health * (System_Global.baseEndRepair * System_Global.endRepairMultiplier * 0.01)
		print(healthToAdd)
		player.currHealth = min(player.currHealth + healthToAdd, player.Health)
	elif enemiesAlive <= 0 and not spawningMiniWave:
		miniWaveOngoing = false

	if timeTillNextMini > 0:
		timeTillNextMini -= delta
		
	if not miniWaveOngoing and waveOngoing:
		timeTillNextMini = randf_range(timeRangeForMini.x, timeRangeForMini.y)
		miniWaveOngoing = true
		spawningMiniWave = true
		#currSpawnMode = SpawnModes.values().pick_random()
		currSpawnMode = SpawnModes.Pulse
		
		print("SpawnMode: ", SpawnModes.keys()[currSpawnMode])
		print("BudgetOption: ", BudgetOptions.keys()[currBudgetOption])
		
	if spawningMiniWave and timeTillNextMini <= 0 and not spawningDataDecided:
		match currBudgetOption:
			BudgetOptions.Observer:
				budgetToUse = min(CurrBudget - (CurrBudget - CurrBaseBudget * .2), CurrBudget)
				pass
			BudgetOptions.BigSpender:
				budgetToUse = min(CurrBaseBudget / 3.0, CurrBudget)
				pass
		spawningDataDecided = true
	if spawningMiniWave and spawningDataDecided:
		trySpawnEnemies(delta)

var budgetToUse: float = 0
var randSpawnInt: Vector2 = Vector2(1, 2)
var randGroupSpawnInt: Vector2 = Vector2(5, 9)
var timeToSpawn: float = 0
func trySpawnEnemies(delta):
	if getValidEnemies(budgetToUse).size() == 0 or getValidEnemies(CurrBudget).size() == 0:
		spawningMiniWave = false
		spawningDataDecided = false
		return
	match currSpawnMode:
		SpawnModes.Rapid:
			if timeToSpawn <= 0:
				var cost = spawnEnemy(budgetToUse)
				budgetToUse -= cost
				CurrBudget -= cost
				timeToSpawn = randf_range(randSpawnInt.x, randSpawnInt.y)
			else:
				timeToSpawn -= delta
			pass
		SpawnModes.Pulse:
			if timeToSpawn <= 0:
				while not getValidEnemies(budgetToUse).size() == 0:
					var cost = spawnEnemy(budgetToUse)
					budgetToUse -= cost
					CurrBudget -= cost
					if randf() < 0.1:
						timeToSpawn = randf_range(randGroupSpawnInt.x, randGroupSpawnInt.y)
						break
			else:
				timeToSpawn -= delta
			pass
	pass

signal enemySpawned
func spawnEnemy(budget):
	var availableEnemies = getValidEnemies(budget)
	var points = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5)
	points = points.normalized() * spawnRadius + player.position
	var pickedEnemy = randByWeight(availableEnemies)
	
	var newEnemy = pickedEnemy.scene.instantiate()
	newEnemy.set_position(points)
	newEnemy.connect("enemyDeath", enemyDied)
	newEnemy.connect("enemyDamaged", System_Global.playerDidDamage)
	
	newEnemy.ID = System_Global.GET_NEWID()
	newEnemy.difficulty = CurrBaseDifficulty + CurrDifficultyOffset
	
	System_Global.EnemyInstances[newEnemy.ID] = newEnemy
	main.add_child.call_deferred(newEnemy)
	enemySpawned.emit(newEnemy.ID)
	enemiesAlive += 1
	return pickedEnemy.cost

signal enemyDead
func enemyDied(id):
	if not enabled:
		return
	if(System_Global.EnemyInstances.erase(id)):
		enemyDead.emit(id)
		enemiesAlive -= 1
		#enemiesKilledSinceSpawn += 1
		score += CurrBaseDifficulty + CurrDifficultyOffset

func WaveDone():
	waveOngoing = false
	main.OpenUpgrades()

func StartNewWave():
	CurrentWave += 1
	CurrBaseBudget = BaseBudget
	CurrBudget = CurrBaseBudget
	WaveUI.SetWaveCount(CurrentWave)
	WaveUI.StartWave(5)
	pass

#Setting up and starting new wave
func _on_wave_ui_wave_started():
	currBudgetOption = BudgetOptions.values().pick_random()
	CurrBaseDifficulty = 1.0 + (CurrentWave - 1) * DifficultyScalePower
	waveOngoing = true


func _on_upgrade_menu_done_pressed():
	main.CloseUpgrades()
	waveOngoing = true
	StartNewWave()

# Objects in array are assumed to have a weight property
func randByWeight(arr: Array):
	var total: float = 0
	for obj in arr:
		total += obj.weight
		
	var random: float = ceil(randf() * total)
	
	var cursor = 0
	for i in arr:
		cursor += i.weight
		if cursor >= random:
			return i
	return null

func getValidEnemies(budget):
	var validEnemies: Array[EnemySpawnDescriptor] = []
	for enemy in enemies:
		if enemy.cost <= budget and enemy.fromRound <= CurrentWave:
			validEnemies.append(enemy)
	return validEnemies
