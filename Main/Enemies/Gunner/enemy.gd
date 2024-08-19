## Enemey Concept - Standard enemy
## Flies toward player while shooting.
## When close to player comes to a stop and rotates to look at player.
## Starts moving when there's x distance between enemy and player again.

extends EnemyBase
#Base variables
@onready var AudioPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var HealthLabel: Label3D = $Label3D

@onready var Player: Node3D = find_parent("Main").find_child("Player")
@onready var FollowTesting: Node3D = find_parent("Main").find_child("FollowTesting")

#Gun variables
@onready var Bullet: PackedScene = preload("res://Main/Enemies/Common/Bullet.tscn")
@onready var Guns = [
	$LeftBackGun,
	$LeftFrontGun,
	$RightBackGun,
	$RightFrontGun
]
@export var FireRate: float = 0.2
@export var accuracyDist: float = 0.9

#Behaviour tree variables
@export var IdleDist: float = 100.0

@export var Health = 100

var FocusPoint: Node3D

func _ready():
	currHealth = Health
	FocusPoint = FollowTesting
	setup()

enum BehaviorStates {
	Idle,
	Following
}

var currBehavior: BehaviorStates = BehaviorStates.Following
var allowedToShoot: bool = true

#Control behavior
func _process(delta):
	if System_Global.GamePaused:
		return
	tryFixShield(delta)
	HealthLabel.text = str(currHealth, "% HP")
	
	#Implement behaviour tree
	if position.distance_to(FocusPoint.position) <= IdleDist:
		currBehavior = BehaviorStates.Idle
	else:
		currBehavior = BehaviorStates.Following

#Perform behavior
func _physics_process(delta):
	if System_Global.GamePaused:
		return
	#Turn followpoint towards point to follow
	turnFollowPoint(FocusPoint.position)
	
	#Execute behaviour
	match currBehavior:
		BehaviorStates.Idle:
			idle(delta)
		BehaviorStates.Following:
			flyToPoint(delta)
	
	if currAccToTarget >= accuracyDist and allowedToShoot:
		ShootAtPlayer(delta)

var timeToNextShot = 0
var gunToShoot: int = 0
func ShootAtPlayer(delta):
	if gunToShoot > Guns.size() - 1:
		gunToShoot = 0
	if timeToNextShot <= 0:
			var newBullet = Bullet.instantiate()
			newBullet.position = Guns[gunToShoot].global_position
			newBullet.rotation = rotation
			Main.add_child(newBullet)
			timeToNextShot = FireRate
			gunToShoot += 1
			AudioPlayer.play(0)
	timeToNextShot -= delta
