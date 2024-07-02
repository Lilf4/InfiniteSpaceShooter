extends CharacterBody3D

@onready var Main = find_parent("Main")
@export var SpeedLabel: Label

@export var ThrustSpeed = 100
@export var accelRate = .5

@export var passiveStopSpeed = 20

var target_velocity = Vector3.ZERO
var currVel = Vector3.ZERO

@export var maxTurnSpeed = .5
@export var turnCutOff = 0.25
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
	
	if Input.is_action_pressed("forward_thrust"):
		dir.z += 1
		relativeDir += transform.basis.z * 1
	if Input.is_action_pressed("backward_thrust"):
		dir.z += -1
		relativeDir += -transform.basis.z * 1
	if Input.is_action_pressed("left_thrust"):
		dir.x += 1
		relativeDir += transform.basis.x * 1
	if Input.is_action_pressed("right_thrust"):
		dir.x += -1 
		relativeDir += -transform.basis.x * 1 
	if Input.is_action_pressed("upward_thrust"):
		dir.y += 1
		relativeDir += transform.basis.y * 1
	if Input.is_action_pressed("downward_thrust"):
		dir.y += -1
		relativeDir += -transform.basis.y * 1
	if Input.is_action_pressed("left_roll"):
		turnVal.z += 5
	if Input.is_action_pressed("right_roll"):
		turnVal.z += -5
	
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
	
	SpeedLabel.text = ""
	
	turnVal = turnVal.clamp(
		-Vector3(maxTurnSpeed,maxTurnSpeed,maxTurnSpeed),
		Vector3(maxTurnSpeed,maxTurnSpeed,maxTurnSpeed)
	)
	turnVal.z = lerp(turnVal.z, 0.0, delta * passiveStopSpeed)
	
	if turnVal.distance_to(Vector3.ZERO) < turnCutOff:
		return
	
	#print(turnVal.distance_to(Vector3.ZERO))
	var yaw = turnVal.x
	var pitch = turnVal.y
	
	rotate_object_local(Vector3(0,1,0), deg_to_rad(-yaw))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(pitch))
	rotate_object_local(Vector3(0,0,1), deg_to_rad(turnVal.z))
