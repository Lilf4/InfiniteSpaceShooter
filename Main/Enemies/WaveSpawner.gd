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
var MaxDifficultySwing: float = 0.6

@export var maxSpawnBonus: float = 100
@export var maxBonusChannce: float = 0.8
@export var budgetRange: Vector2 = Vector2(600,1200)
var CurrBaseBudget: float
var CurrBudget: float

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
	connect("enemyDead", System_Global.playerKilled)
	StartNewWave()

func _process(delta):
	CurrDifficultyOffset = (((System_Global.PlayerPerformance - 0.0) * (MaxDifficultySwing - -MaxDifficultySwing)) / (2.0 - 0.0)) + -MaxDifficultySwing
	if enemiesAlive <= 0 and getValidEnemies(CurrBudget).size() == 0 and waveOngoing:
		budgetProcentToStart = -1
		miniWavesToUseProcent = -1
		accumaletedPerformance = 0
		WaveDone()
		var healthToAdd: float = player.Health * (System_Global.baseEndRepair * System_Global.endRepairMultiplier * 0.01)
		print(healthToAdd)
		player.currHealth = min(player.currHealth + healthToAdd, player.Health)
	elif enemiesAlive <= 0 and not spawningMiniWave:
		miniWaveOngoing = false
		System_Global.PlayerPerfTracking = false
		miniWavesLeft -= 1

	if timeTillNextMini > 0:
		timeTillNextMini -= delta
		
	if not miniWaveOngoing and waveOngoing:
		timeTillNextMini = randf_range(timeRangeForMini.x, timeRangeForMini.y)
		miniWaveOngoing = true
		spawningMiniWave = true
		currSpawnMode = SpawnModes.values().pick_random()
		
		print("SpawnMode: ", SpawnModes.keys()[currSpawnMode])
		print("BudgetOption: ", BudgetOptions.keys()[currBudgetOption])
		
	if spawningMiniWave and timeTillNextMini <= 0 and not spawningDataDecided:
		System_Global.PlayerPerfTracking = true
		accumaletedPerformance += (System_Global.PlayerPerformance - 1) * 0.1
		match currBudgetOption:
			BudgetOptions.Observer:
				#Conservative at start of wave, adapting to player performance
				#aim to use 20-30% at start
				if budgetProcentToStart == -1:
					budgetProcentToStart = randf_range(0.2, 0.3)
					miniWavesToUseProcent = randi_range(2,3)
					miniWavesLeft = miniWavesToUseProcent
				if miniWavesLeft > 0:
					budgetToUse = (CurrBaseBudget * budgetProcentToStart) / miniWavesToUseProcent
					bonusBudget = (randf() * (maxSpawnBonus * (System_Global.PlayerPerformance - 1))) if randf() < maxBonusChannce * (System_Global.PlayerPerformance - 1) else 0.0
				else:
					budgetToUse = CurrBaseBudget * accumaletedPerformance
					if CurrBudget < budgetToUse:
						budgetToUse = CurrBudget
				pass
			BudgetOptions.BigSpender:
				#Spends a lot early on to try and overwhelm the player, 
				#depending on how the player does, cranks budget use down/up
				#aim to use 60-70% early on
				if budgetProcentToStart == -1:
					budgetProcentToStart = randf_range(0.6, 0.7)
					miniWavesToUseProcent = randi_range(3,5)
					miniWavesLeft = miniWavesToUseProcent
				if miniWavesLeft > 0:
					budgetToUse = (CurrBaseBudget * budgetProcentToStart) / miniWavesToUseProcent
					bonusBudget = (randf() * (maxSpawnBonus * (System_Global.PlayerPerformance - 1))) if randf() < maxBonusChannce * (System_Global.PlayerPerformance - 1) else 0.0
				else:
					budgetToUse = CurrBaseBudget * accumaletedPerformance
					if CurrBudget < budgetToUse:
						budgetToUse = CurrBudget
				pass
		spawningDataDecided = true
	if spawningMiniWave and spawningDataDecided:
		trySpawnEnemies(delta)
var budgetProcentToStart = -1
var miniWavesToUseProcent = -1
var miniWavesLeft = -1
var accumaletedPerformance = 0

var budgetToUse: float = 0
var bonusBudget: float = 0
var randSpawnInt: Vector2 = Vector2(1, 2)
var randGroupSpawnInt: Vector2 = Vector2(5, 9)
var timeToSpawn: float = 0
func trySpawnEnemies(delta):
	if getValidEnemies(budgetToUse + bonusBudget).size() == 0 or getValidEnemies(CurrBudget).size() == 0:
		spawningMiniWave = false
		spawningDataDecided = false
		return
	match currSpawnMode:
		SpawnModes.Rapid:
			if timeToSpawn <= 0:
				var cost = spawnEnemy(budgetToUse + bonusBudget)
				var calcedBonus = bonusBudget - cost
				if calcedBonus < 0:
					cost = -calcedBonus
					bonusBudget = 0
				else:
					bonusBudget -= cost
					cost = 0
				budgetToUse -= cost
				CurrBudget -= cost
				timeToSpawn = randf_range(randSpawnInt.x, randSpawnInt.y)
			else:
				timeToSpawn -= delta
			pass
		SpawnModes.Pulse:
			if timeToSpawn <= 0:
				while not getValidEnemies(budgetToUse + bonusBudget).size() == 0:
					var cost = spawnEnemy(budgetToUse + bonusBudget)
					var calcedBonus = bonusBudget - cost
					if calcedBonus < 0:
						cost = -calcedBonus
						bonusBudget = 0
					else:
						bonusBudget -= cost
						cost = 0
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
		score += CurrBaseDifficulty + CurrDifficultyOffset

func WaveDone():
	waveOngoing = false
	main.OpenUpgrades()

func StartNewWave():
	CurrentWave += 1
	CurrBaseBudget = clamp((CurrBaseBudget + budgetRange.x * (System_Global.PlayerPerformance - 1)), budgetRange.x, budgetRange.y)
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
