class_name BaseMine extends Area3D

@onready var mesh = $MeshInstance3D
@onready var particles = $GPUParticles3D

@export var lifetime = 20
@export var damage = 50

var currLifetime = 0
func _process(delta):
	currLifetime += delta
	if currLifetime >= lifetime:
		Implode()

func Implode():
	if particles.emitting:
		return
	mesh.hide()
	particles.emitting = true

func Explode(player):
	if particles.emitting:
		return
	player.takeDamage(damage)
	mesh.hide()
	particles.emitting = true

func _on_body_entered(body):
	Explode(body)

func _on_gpu_particles_3d_finished():
	queue_free()
