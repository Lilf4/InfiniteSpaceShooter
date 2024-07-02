extends Control

var Player

@export var reticleSize = 25

func _ready():
	Player = find_parent("Main").find_child("Player")


func _process(delta):
	queue_redraw()

func _draw():
	if Player == null:
		return
	var distMult = reticleSize * 2
	var screenCenter = get_viewport_rect().size * .5
	var mouseOffset = (Vector2(Player.turnVal.x, Player.turnVal.y) * distMult)
	
	#Cursor
	draw_arc(screenCenter + mouseOffset, reticleSize * .5, 0, TAU, 100, Color.WHITE)
	#Deadzone
	draw_arc(screenCenter, reticleSize + Player.turnCutOff, 0, TAU, 100, Color.ORANGE)
	#Max
	draw_arc(screenCenter, (reticleSize + Player.maxTurnSpeed) + (reticleSize * Player.maxTurnSpeed), 0, TAU, 100, Color.RED)
