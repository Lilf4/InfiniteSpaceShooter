extends CharacterBody3D
## Concept of enemy movement
## Enemy will try to move towards a follow point which gets moved further/closer to control the speed of the enemy
## Using a follow point with more "realistic" restrictions/movement fx making the point need to be moved over time-
## to point toward the player allows for enemies to make "realistic" turning manuevers with less complications
@onready var Scrap = preload("res://Main/Pickups/Scrap.tscn")
@onready var Main: Node = find_parent("Main")
@onready var Player: Node3D = find_parent("Main").find_child("Player")

@onready var Bullet: PackedScene = preload("res://Main/Enemy/Bullet.tscn")
@onready var LeftBackGun: Node3D = $LeftBackGun
@onready var LeftFrontGun: Node3D = $LeftFrontGun
@onready var RightBackGun: Node3D = $RightBackGun
@onready var RightFrontGun: Node3D = $RightFrontGun

var Guns = []

@export var SeperationDistMargin: float = 10.0
@export var SeperationDist: float = 30.0
@export var SeperationForce: float = .5

@export var MaxSpeed: Vector3 = Vector3(50.0, 50.0, 50.0)
@export var AccelRate: float = 10.0
@export var Thrust: float = 5.0
@export var StoppingPower: float = 5.0

@export var FollowForgiveness: float = 10.0
@export var FollowingDistance: float = 60.0

@export var FireRate: float = 0.2

@export var followPointRadius: float = 20
@onready var followPointScene: PackedScene = preload("res://Main/Enemy/follow_point.tscn")
@onready var followPointMiddle: Node3D
@onready var followPointOuter: Node3D
var followPointOffset: Vector3 = Vector3(0, 0, -20)

var currVel: Vector3 = Vector3.ZERO

@onready var AudioPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var HealthLabel: Label3D = $Label3D


@export var Health = 100
var currHealth = 0

var ID = 0

signal enemyDeath
func takeDamage(val):
	currHealth -= val
	if currHealth <= 0:
		enemyDeath.emit(ID)
		spawnScrapPile(true, 75)
		followPointMiddle.queue_free()
		queue_free()

func spawnScrapPile(random: bool, percentage: int):
	var shouldSpawn: bool = true
	if random:
		shouldSpawn = randi_range(0, 100) >= 100 - percentage
	
	if shouldSpawn:
		var scrapPile = Scrap.instantiate()
		scrapPile.position = position
		Main.add_child(scrapPile)

func _ready():
	Guns.append(LeftFrontGun)
	Guns.append(LeftBackGun)
	Guns.append(RightFrontGun)
	Guns.append(RightBackGun)
	currHealth = Health
	followPointMiddle = followPointScene.instantiate()
	find_parent("Main").add_child(followPointMiddle)
	followPointOuter = followPointMiddle. find_child("FollowPointOuter")

enum BehaviorStates {
	Idle,
	Following,
	Flyby,
	Dogfight
}

var currBehavior: BehaviorStates = BehaviorStates.Following
var allowedToShoot: bool = true
var rotDistToPlayer: float = 0

@export var accuracyDist: float = 0.002


#Control behavior
func _process(_delta):
	if System_Global.GamePaused:
		return
	HealthLabel.text = str(currHealth, "% HP")
	followPointMiddle.position = position
	followPointOuter.position = followPointOffset

#Perform behavior
func _physics_process(delta):
	if System_Global.GamePaused:
		return
	match currBehavior:
		BehaviorStates.Idle:
			Idle(delta)
		BehaviorStates.Following:
			Following(delta)
	
	if rotDistToPlayer <= accuracyDist and allowedToShoot:
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

func Flyby(_delta):
	pass #TODO: Implement behaviour

func Idle(_delta):
	pass #TODO: Implement behaviour

func Following(delta):
	var pointToFollow = followPointOuter.global_position
	
	var movDir = position.direction_to(pointToFollow)
	var target_velocity = movDir * Thrust
	
	currVel += (target_velocity * AccelRate) * delta
	
	currVel -= currVel.lerp(Vector3.ZERO, delta * StoppingPower) * delta

	currVel.clamp(-MaxSpeed, MaxSpeed)
	
	velocity = currVel
	
	if not global_position.is_equal_approx(global_position + -currVel):
		look_at(global_position + -currVel)
	else:
		look_at(Player.position)
	
	move_and_slide()
	
	if not followPointMiddle.position.is_equal_approx(Player.position):
		var before = followPointMiddle.rotation
		followPointMiddle.look_at(Player.position)
		var after = followPointMiddle.rotation
		rotDistToPlayer = before.distance_to(after)
		followPointMiddle.rotation = before.lerp(after, 0.2)

func LegacyFollowing(delta):
	var pointToFollow = Player.position - (-Player.position.direction_to(position) * FollowingDistance) 
	
	var movDir = position.direction_to(pointToFollow)
	var target_velocity = movDir * Thrust
	
	var clampedDist = clamp(position.distance_to(pointToFollow), 0, 100)
	var distThrustPower = 0 if clampedDist <= FollowForgiveness else clampedDist * 0.01
	
	target_velocity *= distThrustPower
	
	for enemy in System_Global.EnemyInstances:
		if enemy != ID:
			enemy = System_Global.EnemyInstances[enemy]
			var seperationPointToFollow = enemy.position - (-enemy.position.direction_to(position) * SeperationDist)
			
			var SepDir = position.direction_to(seperationPointToFollow)
			var sepVelocity = SepDir * SeperationForce
			
			var clampedSeperationDist = SeperationDist - clamp(position.distance_to(seperationPointToFollow), 0, SeperationDist)
			var seperationThrustPower = 0 if clampedSeperationDist <= SeperationDistMargin else clampedSeperationDist * 0.1
			
			sepVelocity *= seperationThrustPower
			
			target_velocity += -sepVelocity
	
	currVel += (target_velocity * AccelRate) * delta
	
	currVel -= currVel.lerp(Vector3.ZERO, delta * StoppingPower) * delta
	
	currVel.clamp(-MaxSpeed, MaxSpeed)
	
	velocity = currVel
	
	if not global_position.is_equal_approx(global_position + -currVel):
		look_at(global_position + -currVel)
	else:
		look_at(Player.position)
	
	move_and_slide()
