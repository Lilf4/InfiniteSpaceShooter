extends Node

@onready var starScene = preload("res://Mob.tscn")

@export var radius = 1500
@export var density = .000005

func _ready():
	spawnFilledSphere()
	#spawnSurface()

func spawnSurface():
	for i in range(4 * (PI * pow(radius, 2)) * density) :
		var points = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5)
		points = points.normalized()
		var newStar = starScene.instantiate()
		newStar.set_position(points * radius)
		self.add_child(newStar)

func spawnFilledSphere():
	for i in range(4 / 3 * (PI * pow(radius, 3)) * density) :
		var d = 0.0
		var x = 0.0
		var y = 0.0
		var z = 0.0
		while true:
			x = randf() * 2.0 - 1.0
			y = randf() * 2.0 - 1.0
			z = randf() * 2.0 - 1.0
			d = x*x + y*y + z*z
			if d <= 1.0:
				break
		var newStar = starScene.instantiate()
		newStar.set_position(Vector3(x, y ,z) * radius)
		self.add_child(newStar)

