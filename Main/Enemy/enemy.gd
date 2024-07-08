extends CharacterBody3D
## Concept of enemy movement
## Enemy will try to move towards a follow point which gets moved further/closer to control the speed of the enemy
## Using a follow point with more "realistic" restrictions/movement fx making the point need to be moved over time-
## to point toward the player allows for enemies to make "realistic" turning manuevers with less complications

@onready var player = find_parent("Main").find_child("Player")

@export var SeperationDistMargin: float = 10.0
@export var SeperationDist: float = 30.0
@export var SeperationForce: float = .5

@export var MaxSpeed: Vector3 = Vector3(50.0, 50.0, 50.0)
@export var AccelRate: float = 10.0
@export var Thrust: float = 5.0
@export var StoppingPower: float = 5.0

@export var FollowForgiveness: float = 10.0
@export var FollowingDistance: float = 60.0

@export var followPointRadius: float = 20
@onready var followPointScene: PackedScene = preload("res://Main/Enemy/follow_point.tscn")
@onready var followPointMiddle: Node3D
@onready var followPointOuter: Node3D
var followPointOffset: Vector3 = Vector3(0, 0, 20)

var currVel: Vector3 = Vector3.ZERO


@export var Health = 100
var currHealth = 0

var ID = 0

signal enemyDeath
func takeDamage(val):
	currHealth -= val
	if currHealth <= 0:
		enemyDeath.emit(ID)
		followPointMiddle.queue_free()
		queue_free()

func shoot():
	pass

func _ready():
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

#Control behavior
func _process(_delta):
	followPointMiddle.position = position
	followPointOuter.position = followPointOffset

#Perform behavior
func _physics_process(delta):
	match currBehavior:
		BehaviorStates.Idle:
			Idle(delta)
		BehaviorStates.Following:
			Following(delta)

func Dogfight(delta):
	pass

func Flyby(delta):
	pass

func Idle(delta):
	pass

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
		look_at(player.position)
	
	#move_and_slide()
	
	var v = Vector2(followPointMiddle.global_position.x, followPointMiddle.global_position.y) - Vector2(player.global_position.x, player.global_position.y)
	var angle = v.angle()
	var r = Vector2(followPointMiddle.global_rotation.x, followPointMiddle.global_rotation.y)
	var lerpedRot = lerp(r, Vector2(angle,angle), 0.2)
	followPointMiddle.global_rotation = Vector3(lerpedRot.x, lerpedRot.y , 0)
	#Get angle in y dir and apply
	#Get angle in z dir and apply
	#print("Toward player: ", towardPlayer, "\r\n", "Current: ", currLook, "\r\n", "Difference: ", currLook - towardPlayer)
	#moveFollowPoint((towardPlayer - currLook).normalized(), 50 * delta)

func LegacyFollowing(delta):
	var pointToFollow = player.position - (-player.position.direction_to(position) * FollowingDistance) 
	
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
		look_at(player.position)
	
	move_and_slide()


#FIX DOT ROTATING WITH SHIP ENDING IN INSANE BAYBLADE SPINNING
func moveFollowPoint(dir: Vector3, amount: float):
	followPointMiddle.rotate_object_local(dir, deg_to_rad(amount))
	#print(followPointMiddle.rotation, amount)
