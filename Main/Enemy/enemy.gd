extends CharacterBody3D

@onready var player = find_parent("Main").find_child("Player")

@export var SeperationDistMargin: float = 2.0
@export var SeperationDist: float = 10.0
@export var SeperationForce: float = .1

@export var MaxSpeed: Vector3 = Vector3(50.0, 50.0, 50.0)
@export var AccelRate: float = 10.0
@export var Thrust: float = 5.0
@export var StoppingPower: float = 5.0

@export var FollowForgiveness: float = 10.0
@export var FollowingDistance: float = 60.0

var pointToMove: Vector3 = Vector3.ZERO

var currVel: Vector3 = Vector3.ZERO


@export var Health = 100
var currHealth = 0

var ID = 0

signal enemyDeath
func takeDamage(val):
	currHealth -= val
	if currHealth <= 0:
		enemyDeath.emit(ID)
		queue_free()

func shoot():
	pass

func _ready():
	currHealth = Health

enum BehaviorStates {
	Idle,
	Following,
	Flyby
}

var currBehavior: BehaviorStates = BehaviorStates.Following

#Control behavior
func _process(delta):
	pass

#Perform behavior
func _physics_process(delta):
	match currBehavior:
		BehaviorStates.Idle:
			Idle(delta)
		BehaviorStates.Following:
			Following(delta)
	
	if not global_position.is_equal_approx(global_position + -currVel):
		look_at(global_position + -currVel)
	else:
		look_at(player.position)
func Idle(delta):
	pass
	
func Following(delta):
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
			var clampedSeperationDist = clamp(position.distance_to(seperationPointToFollow), 0, 100)
			var seperationThrustPower = 0 if clampedSeperationDist <= SeperationDistMargin else clampedSeperationDist * 0.01
			print((position.direction_to(enemy.position) * -SeperationForce) * seperationThrustPower)
			target_velocity += (position.direction_to(enemy.position) * -SeperationForce) * seperationThrustPower
	
	currVel += (target_velocity * AccelRate) * delta
	
	currVel -= currVel.lerp(Vector3.ZERO, delta * StoppingPower) * delta
	
	currVel.clamp(-MaxSpeed, MaxSpeed)
	
	velocity = currVel
	
	move_and_slide()
