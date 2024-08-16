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
		return
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
