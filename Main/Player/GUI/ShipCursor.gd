extends Control

@onready var Player = find_parent("Main").find_child("Player")

@onready var Main = find_parent("Main")
@export var reticleSize = 20
@export var width = 1

@export var enableReticle: bool = true
@export var enableCursor: bool = true
@export var enableDeadzone: bool = true
@export var enableMaxTurn: bool = true



func _ready():
	pass

func _process(_delta):
	if System_Global.GamePaused:
		#return
		pass
	queue_redraw()

func _draw():
	if Player == null or not enableReticle:
		return
	var mouseOffset = (Vector2(Player.turnVal.x, Player.turnVal.y) * (reticleSize)) 
	
	if enableDeadzone:
		#Deadzone
		draw_arc(
			Vector2.ZERO, 
			((reticleSize * .5) + reticleSize * Player.turnCutOff) - width,
			0, TAU, 100, Color.ORANGE, width)
	
	if enableMaxTurn:
		#Max
		draw_arc(
			Vector2.ZERO, 
			(reticleSize * .5 + reticleSize) - width, 
			0, TAU, 100, Color.RED, width)
	
	if enableCursor:
		#Cursor
		draw_arc(
			mouseOffset, 
			(reticleSize * .5) - width, 
			0, TAU, 100, Color.WHITE, width)
			
	
	var playerFacing = -Player.transform.basis.z
	#TODO
	var EnemyToDisplay
	var smallestDist: float = INF
	for enemy in System_Global.EnemyInstances:
		var enemyInstance = System_Global.EnemyInstances[enemy]
		if enemyInstance.isVisible:
			if smallestDist > (enemyInstance.position - enemyInstance.position * playerFacing).distance_to(Player.position - Player.position * playerFacing):
				EnemyToDisplay = System_Global.EnemyInstances[enemy]
				smallestDist = (enemyInstance.position - enemyInstance.position * playerFacing).distance_to(Player.position - Player.position * playerFacing)
	
	var health = 0 if EnemyToDisplay == null or EnemyToDisplay.currHealth == 0 else EnemyToDisplay.currHealth / EnemyToDisplay.Health
	var shield = 0 if EnemyToDisplay == null or EnemyToDisplay.currShield == 0 else EnemyToDisplay.currShield / EnemyToDisplay.MaxShield
	var innerRadius = (reticleSize * .5 + reticleSize) - width
	var enemyInfoRadius = (reticleSize * 1.75 + reticleSize) - width + 2
	var difference = innerRadius / enemyInfoRadius
	var newAngle = .33 * difference
	var shieldValue = (1 - shield) * newAngle
	var healthValue = (1 - health) * newAngle
	
	draw_arc(
			Vector2(0,0), 
			enemyInfoRadius, 
			TAU * ((0.5 + newAngle * 0.5)), TAU * (0.5 - newAngle * 0.5), 100, Color(Color.WHITE, 0.2), width + 2)
	
	draw_arc(
			Vector2(0,0), 
			enemyInfoRadius, 
			TAU * ((0.5 + newAngle * 0.5) - shieldValue), TAU * (0.5 - newAngle * 0.5), 100, Color.BLUE, width + 2)
	
	draw_arc(
			Vector2(0,0), 
			enemyInfoRadius, 
			TAU * (newAngle * 0.5), TAU * ((-newAngle * 0.5)), 100, Color(Color.WHITE, 0.2), width + 2)
	
	draw_arc(
			Vector2(0,0), 
			enemyInfoRadius, 
			TAU * (newAngle * 0.5), TAU * ((-newAngle * 0.5) + healthValue), 100, Color.RED, width + 2)
