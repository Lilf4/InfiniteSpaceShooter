extends Node3D

@onready var Main = find_parent("Main")
@onready var Player = find_parent("Player")
@onready var bullet = preload("res://Bullet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var fireRate = .05

var timeToNextShot = 0
func _process(delta):
	if Input.is_action_pressed("shoot"):
		if timeToNextShot <= 0:
			var newBullet = bullet.instantiate()
			newBullet.position = global_position
			newBullet.rotation = Player.rotation
			newBullet.set_collision_layer_value(2, true)
			Main.add_child(newBullet)
			timeToNextShot = fireRate

	timeToNextShot -= delta
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _unhandled_input(event):
	#if event is InputEvent and event.is_action("shoot"):
		#var newBullet = bullet.instantiate()
		#newBullet.position = global_position
		#newBullet.rotation = Player.rotation
		#newBullet.set_collision_layer_value(2, true)
		#Main.add_child(newBullet)
