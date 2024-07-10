extends Node3D

@onready var Player = find_parent("Main").find_child("Player")
@onready var DirPivot = $DirPivot

var Test: Draw3D = Draw3D.new()

func _ready():
	add_child(Test)
	pass

func _physics_process(delta):
	print(Player.target_velocity.normalized())
	Test.clear()
	print(Player.velocity.dot(Player.global_transform.basis.z)) 
	Test.draw_line([Vector3.ZERO, Player.velocity.normalized() * Player.global_transform.basis.z * 50])
	pass
