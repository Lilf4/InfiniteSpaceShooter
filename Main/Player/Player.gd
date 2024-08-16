extends CharacterBody3D

@onready var Main: Node = find_parent("Main")

var currHealth: float = 0
@export var Health: float = 100

@export var ThrustSpeed: float = 100
@export var accelRate: float = .5

@export var passiveStopSpeed: float = 20

var target_velocity: Vector3 = Vector3.ZERO
var currVel: Vector3 = Vector3.ZERO
var currRoll: float = 0
@export var maxRollSpeed: float = 10.0
@export var rollAccel: float = 0.5
@export var rollForce: float = 5.0
@export var rollStopForce: float = 1.0

@export var maxTurnSpeed: float = 2
@export var turnCutOff: float = 0.2
var turnVal: Vector3 = Vector3.ZERO

func _ready():
	currHealth = Health
	
signal PlayerDeath
func takeDamage(val):
	currHealth -= val
	if currHealth <= 0:
		PlayerDeath.emit()

func _input(event):
	if System_Global.GamePaused:
		return
	if event is InputEventMouseMotion:
		turnVal += Vector3(event.relative.x, event.relative.y, 0) * 0.001
		var clamped: Vector2 = clamp_vector(Vector2(turnVal.x, turnVal.y), Vector2.ZERO, 1)
		turnVal = Vector3(clamped.x, clamped.y, 0)

func clamp_vector(vector, clamp_origin, clamp_length):
	var offset = vector - clamp_origin
	var offset_length = offset.length()
	if offset_length <= clamp_length:
		return vector
	return clamp_origin + offset * (clamp_length / offset_length)

func _physics_process(delta):
	if System_Global.GamePaused:
		return
	var dir = Vector3.ZERO
	var relativeDir = Vector3.ZERO
	var roll: int = 0
	if Input.is_action_pressed("forward_thrust"):
		dir.z += 1
		relativeDir += transform.basis.z * 1
	if Input.is_action_pressed("backward_thrust"):
		dir.z += -1
		relativeDir += -transform.basis.z * 1
	if Input.is_action_pressed("left_roll"):
		roll += -1
	if Input.is_action_pressed("right_roll"):
		roll += 1
	
	if dir != Vector3.ZERO:
		dir.normalized()
		relativeDir.normalized()
	 
	target_velocity = relativeDir * ThrustSpeed
	
	#Apply velocity with time and accel rate applied
	currVel += (target_velocity * accelRate) * delta
	
	#Clamp velocity
	currVel = currVel.clamp(
		-Vector3(ThrustSpeed, ThrustSpeed, ThrustSpeed), 
		Vector3(ThrustSpeed, ThrustSpeed, ThrustSpeed)
	)
	
	#Apply passive stopping force
	currVel -= currVel.lerp(Vector3.ZERO, delta * passiveStopSpeed) * delta
	if dir == Vector3.ZERO and currVel.distance_to(Vector3.ZERO) < 0.5:
		currVel = Vector3.ZERO
	
	velocity = currVel
	
	move_and_slide()
	
	currRoll += ((roll * rollForce) * rollAccel) * delta
	
	currRoll = lerp(currRoll, 0.0, delta * rollStopForce)
	
	rotate_object_local(Vector3(0,0,1), deg_to_rad(currRoll))
	
	if Vector2(turnVal.x,turnVal.y).distance_to(Vector2.ZERO) < turnCutOff:
		return
	
	var yaw = turnVal.x * maxTurnSpeed
	var pitch = turnVal.y * maxTurnSpeed
	
	rotate_object_local(Vector3(0,1,0), deg_to_rad(-yaw))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(pitch))
