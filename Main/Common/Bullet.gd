extends CharacterBody3D

@export var lifeTime = 5
@export var Speed = 600

@export var Damage = 10

var timeLeft = 0

func _ready():
	System_Global.BulletsShot += 1
	timeLeft = 10

func _process(delta):
	if System_Global.GamePaused:
		return
	timeLeft -= delta
	if timeLeft < 0:
		queue_free()

func _physics_process(_delta):
	if System_Global.GamePaused:
		return
	velocity = transform.basis.z * Speed
	move_and_slide()


func _on_area_3d_body_entered(body):
	if ($GPUParticles3D as GPUParticles3D).emitting:
		return
	body.takeDamage(Damage)
	($MeshInstance3D as MeshInstance3D).hide()
	($GPUParticles3D as GPUParticles3D).emitting = true
	System_Global.BulletsHit += 1


func _on_area_3d_area_entered(area):
	if area.is_in_group("Mine"):
		area.Implode()
		queue_free()
	System_Global.BulletsHit += 1


func _on_gpu_particles_3d_finished():
	queue_free()
