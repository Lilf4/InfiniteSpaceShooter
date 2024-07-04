extends MeshInstance3D

@onready var player = find_parent("Main").find_child("Player")
@export var offset: Vector3 = Vector3(0,0,2000)
@export var movPow = 0.05
var basePos: Vector3
# Called when the node enters the scene tree for the first time.
func _ready():
	position = player.position + offset
	basePos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = player.position + offset
