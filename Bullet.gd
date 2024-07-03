extends CharacterBody3D

@export var lifeTime = 10
@export var Speed = 300

@export var Damage = 10

var timeLeft = 0

func _ready():
	timeLeft = 10

func _process(delta):
	timeLeft -= delta
	if timeLeft < 0:
		queue_free()

func _physics_process(delta):
	velocity = transform.basis.z * Speed
	move_and_slide()


func _on_area_3d_body_entered(body):
	body.takeDamage(Damage)
	print(body.position)
	queue_free()
