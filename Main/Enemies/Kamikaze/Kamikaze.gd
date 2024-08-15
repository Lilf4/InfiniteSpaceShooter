extends EnemyBase

@onready var mesh: MeshInstance3D = $MeshInstance3D
var shader: ShaderMaterial
@onready var Player: CharacterBody3D = find_parent("Main").find_child("Player")
@onready var FollowTest: MeshInstance3D = find_parent("Main").find_child("FollowTesting")

@onready var e = find_parent("Main").find_child("WaveSpawner")

@export_range(0,1) var minInvis: float = 0.3
@export_range(0,1) var maxInvis: float = 1
@export var minDist: float = 50
@export var maxDist: float = 200

@export var passiveCircleRadius: float = 500
@export var attackChance: int = 90

@export var minDistToPoint: float = 100
var currPoint: Vector3
var lastActionAttack: bool = false
func _ready():
	shader = mesh.material_override
	setup()
	ID = System_Global.GET_NEWID()
	System_Global.EnemyInstances[ID] = self
	e.enemySpawned.emit(ID)

var chanceTime = 0
func _process(_delta):
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
	turnFollowPoint(currPoint + Player.position)
	flyToPoint(delta)
