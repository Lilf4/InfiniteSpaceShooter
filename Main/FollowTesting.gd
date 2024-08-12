extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var e: float = 10
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var move: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("moveTestForward"):
		move.z += 1
	if Input.is_action_pressed("moveTestBackward"):
		move.z -= 1
	if Input.is_action_pressed("moveTestRight"):
		move.x -= 1
	if Input.is_action_pressed("moveTestLeft"):
		move.x += 1
	if Input.is_action_pressed("moveTestUp"):
		move.y += 1
	if Input.is_action_pressed("moveTestDown"):
		move.y -= 1
	position += move * e
