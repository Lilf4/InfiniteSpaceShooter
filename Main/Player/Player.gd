extends CharacterBody3D

@onready var Main = find_parent("Main")
@export var SpeedLabel: Label

@export var ThrustSpeed = 100
@export var accelRate = .5

@export var passiveStopSpeed = 20

var target_velocity = Vector3.ZERO
var currVel = Vector3.ZERO
var currRoll: float = 0
@export var maxRollSpeed = 10.0
@export var rollAccel = 0.5
@export var rollForce = 5.0
@export var rollStopForce = 1.0

@export var maxTurnSpeed = .5
@export var turnCutOff = 0.1
var turnVal = Vector3.ZERO

func _input(event):
	if Main.game_paused:
		return
	if event is InputEventMouseMotion:
		turnVal += Vector3(event.relative.x, event.relative.y, 0) * 0.001

func _physics_process(delta):
	if Main.game_paused:
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
	
	SpeedLabel.text = str("Velocity: ", round(currVel*pow(10,2))/pow(10,2))
	
	turnVal = turnVal.clamp(
		-Vector3(maxTurnSpeed,maxTurnSpeed,maxTurnSpeed),
		Vector3(maxTurnSpeed,maxTurnSpeed,maxTurnSpeed)
	)
	currRoll += ((roll * rollForce) * rollAccel) * delta
	
	currRoll = lerp(currRoll, 0.0, delta * rollStopForce)
	
	rotate_object_local(Vector3(0,0,1), deg_to_rad(currRoll))
	
	if turnVal.distance_to(Vector3.ZERO) < turnCutOff:
		return
	
	#print(turnVal.distance_to(Vector3.ZERO))
	var yaw = turnVal.x
	var pitch = turnVal.y
	
	rotate_object_local(Vector3(0,1,0), deg_to_rad(-yaw))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(pitch))