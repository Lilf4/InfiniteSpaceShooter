##Base class for enemies
##Contains basic functions for controlling enemy ai behaviour
##Including taking care of movement
class_name EnemyBase extends CharacterBody3D

@onready var Scrap = preload("res://Main/Pickups/Scrap.tscn")
@onready var Main: Node = find_parent("Main")

@onready var followPointScene: PackedScene = preload("res://Main/Enemies/follow_point.tscn")
var followPointMiddle: Node3D
var followPointOuter: Node3D

#Accuracy value between 1-0, 1 = looking dead on target
var currAccToTarget: float = 0

var ID = 0

@export var StoppingPower: float = 5.0
@export var idleTurnWeight: float = 0.05
@export var moveTurnWeight: float = 0.02
@export var AccelRate: float = 10.0
@export var Thrust: float = 5.0
@export var MaxSpeed: Vector3 = Vector3(50.0, 50.0, 50.0)
var difficulty: float = 1.0

var currVel: Vector3 = Vector3.ZERO

var MaxShield: float = 0
var currShield: float = 0

var shieldRepairTime: float = 15
var timeTillRepair: float = 0
var shieldRepairRate: float = 1

var currHealth: float = 0

func tryFixShield(delta):
	if timeTillRepair > 0:
		timeTillRepair -= delta
		return
	if currShield < MaxShield:
		currShield += shieldRepairRate * delta

signal enemyDeath
func takeDamage(val):
	if currShield > 0:
		currShield = max(currShield - val, 0)
		timeTillRepair = shieldRepairTime
	else:
		currHealth -= val
	
	if currHealth <= 0:
		followPointMiddle.queue_free()
		spawnScrapPile(true, 75)
		enemyDeath.emit(ID)
		queue_free()

func spawnScrapPile(random: bool, percentage: int):
	var shouldSpawn: bool = true
	if random:
		shouldSpawn = randi_range(0, 100) >= 100 - percentage
	if shouldSpawn:
		var scrapPile = Scrap.instantiate()
		scrapPile.position = position
		Main.add_child(scrapPile)

#Setup followpoints
func setup():
	followPointMiddle = followPointScene.instantiate()
	find_parent("Main").add_child.call_deferred(followPointMiddle)
	followPointOuter = followPointMiddle.find_child("FollowPointOuter")

func setBaseValues():
	pass

#Lets enemy come to a slow stop, slowly rotating towards followpoint
func idle(delta):
	var before = global_transform.basis.get_rotation_quaternion()
	look_at(followPointOuter.global_position, Vector3.UP, true)
	var after = global_transform.basis.get_rotation_quaternion()
	var interpolated_rotation = before.slerp(after, idleTurnWeight)
	rotation = interpolated_rotation.get_euler()
	
	currVel -= currVel.lerp(Vector3.ZERO, delta * StoppingPower) * delta
	currVel.clamp(-MaxSpeed, MaxSpeed)
	velocity = currVel
	move_and_slide()

#Makes enemy move towards followPoint, also rotates enemy based on velocity
func flyToPoint(delta):
	var pointToFollow = followPointOuter.global_position
	
	var movDir = position.direction_to(pointToFollow)
	var target_velocity = movDir * Thrust
	
	currVel += (target_velocity * AccelRate) * delta
	currVel -= currVel.lerp(Vector3.ZERO, delta * StoppingPower) * delta
	currVel = currVel.clamp(-MaxSpeed, MaxSpeed)
	
	velocity = currVel
	
	#Turn toward velocity unless velocity is close to zero, in which case we rotate toward the follow point
	if not global_position.is_equal_approx(global_position + -currVel):
		look_at(global_position + -currVel)
	else:
		look_at(pointToFollow)
	move_and_slide()

#Turns followpoint towards target
func turnFollowPoint(target: Vector3):
	followPointMiddle.position = position
	if not followPointMiddle.position.is_equal_approx(target):
		var before = followPointMiddle.global_transform.basis.get_rotation_quaternion()
		followPointMiddle.look_at(target)
		var after = followPointMiddle.global_transform.basis.get_rotation_quaternion()
		
		var look_dir = transform.basis.z.normalized()
		var target_dir = (target - global_transform.origin).normalized()
		var dot_product = look_dir.dot(target_dir)
		var angle_diff = acos(dot_product)
		currAccToTarget = 1.0 - (angle_diff / PI)
		
		var interpolated_rotation = before.slerp(after, moveTurnWeight)
		followPointMiddle.rotation = interpolated_rotation.get_euler()
