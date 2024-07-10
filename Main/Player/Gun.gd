extends Node3D

@onready var Main = find_parent("Main")
@onready var Player = find_parent("Player")
@onready var bullet = preload("res://Main/Common/Bullet.tscn")

var fireRate = .05

var timeToNextShot = 0
func _process(delta):
	if System_Global.GamePaused:
		return
	if Input.is_action_pressed("shoot"):
		if timeToNextShot <= 0:
			var newBullet = bullet.instantiate()
			newBullet.position = global_position
			newBullet.rotation = Player.rotation
			newBullet.set_collision_layer_value(2, true)
			Main.add_child(newBullet)
			timeToNextShot = fireRate
	timeToNextShot -= delta
