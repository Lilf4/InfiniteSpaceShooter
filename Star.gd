extends Node3D

@onready var mesh = $MeshInstance3D

@export var minSize = 1
@export var maxSize = 3
@export var minTimeToChange = 5
@export var maxTimeToChange = 8

var originalSize = 0
var minChangePercantage = -0.4
var maxChangePercantage = 0.4

func _ready():
	originalSize = randf_range(minSize, maxSize)
	scale = scale * originalSize

var timeToChange = 0
var timePassed = 0
func _process(delta):
	if timePassed > timeToChange:
		var rand = originalSize + originalSize * randf_range(minChangePercantage, maxChangePercantage) 
		scale = Vector3(rand, rand, rand)
		timeToChange = randf_range(minTimeToChange, maxTimeToChange)
		timePassed = 0
	timePassed += delta
