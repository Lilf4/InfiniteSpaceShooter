extends EnemyBase

@onready var mesh: MeshInstance3D = $MeshInstance3D
var shader: ShaderMaterial
@onready var Player: CharacterBody3D = find_parent("Main").find_child("Player")
@onready var Particles: GPUParticles3D = $GPUParticles3D
@onready var MeshInstance: MeshInstance3D = $MeshInstance3D
@export_range(0,1) var minInvis: float = 0.3
@export_range(0,1) var maxInvis: float = 1
@export var minDist: float = 50
@export var maxDist: float = 200

@export var passiveCircleRadius: float = 500
@export var attackChance: int = 90

@export var minDistToPoint: float = 100

@export var Damage: float = 80

var currPoint: Vector3
var lastActionAttack: bool = false
func _ready():
	shader = mesh.material_override
	setup()

var chanceTime = 0
func _process(delta):
	if System_Global.GamePaused:
		return
	var dist = max(minDist, min(maxDist, position.distance_to(Player.position)))
	var newTransparency = ((maxDist-dist)*(maxInvis-minInvis)/(maxDist-minDist))+minInvis
	shader.set_shader_parameter("dissolve_amount", newTransparency)
	
	if position.distance_to(currPoint + Player.position) <= minDistToPoint:
		if not lastActionAttack and randi_range(0,100) <= attackChance:
			currPoint = Vector3.ZERO
			lastActionAttack = true
			print("Attack")
		else:
			currPoint = pickAPoint()
			lastActionAttack = false
	

func pickAPoint():
	return Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5).normalized() * passiveCircleRadius

func _physics_process(delta):
	if System_Global.GamePaused:
		return
	turnFollowPoint(currPoint + Player.position)
	flyToPoint(delta)


func _on_area_3d_body_entered(body):
	if Particles.emitting:
		return
	Particles.emitting = true
	MeshInstance.hide()
	body.takeDamage(Damage)


func _on_gpu_particles_3d_finished():
	takeDamage(10000)
