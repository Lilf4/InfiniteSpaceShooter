extends Control

var Player
@onready var Cursor = $Cursor

@export var reticleSize = 25

func _ready():
	Player = find_parent("Main").find_child("Player")


func _process(delta):
	queue_redraw()

func _draw():
	if Player == null:
		return
	var screenCenter = get_viewport_rect().size * .5
	var cursorOffsetToCenter = screenCenter - Cursor.size * .5
	var mouseOffset = Vector2(Player.turnVal.x, Player.turnVal.y) * reticleSize
	draw_arc(screenCenter + mouseOffset, reticleSize, 0, TAU, 100, Color.WHITE)
	draw_arc(screenCenter, reticleSize + Player.turnCutOff, 0, TAU, 100, Color.RED)
