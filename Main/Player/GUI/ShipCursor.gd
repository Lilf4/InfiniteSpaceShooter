extends Control

@onready var Player = find_parent("Main").find_child("Player")

@onready var Main = find_parent("Main")
@export var reticleSize = 25

func _ready():
	pass

func _process(_delta):
	if(Main.game_paused):
		return
	queue_redraw()

func _draw():
	if Player == null:
		return
	var distMult = 2
	var screenCenter = get_viewport_rect().size * .5
	var mouseOffset = (Vector2(Player.turnVal.x, Player.turnVal.y) * (reticleSize * distMult)) 
	
	#Cursor
	draw_arc(
		screenCenter + mouseOffset, 
		reticleSize * .5, 
		0, TAU, 100, Color.WHITE)
		
	#Deadzone
	draw_arc(
		screenCenter, 
		reticleSize + (reticleSize * Vector2(Player.turnCutOff, Player.turnCutOff).distance_to(Vector2.ZERO)),
		0, TAU, 100, Color.ORANGE)
		
	#Max
	draw_arc(
		screenCenter, 
		(reticleSize + Player.maxTurnSpeed) + (reticleSize * Player.maxTurnSpeed), 
		0, TAU, 100, Color.RED)
