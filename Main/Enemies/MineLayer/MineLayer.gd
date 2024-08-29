## Enemy that doesn't shoot instead opting to flying around and laying mines 
## around the player which deals a decent amount of damage if flewn into
extends EnemyBase

@onready var mineScene = preload("res://Main/Enemies/Common/Mine/Mine.tscn")
@onready var player = find_parent("Main").find_child("Player")
@export var Health: int = 200
@export var circleRadius: float = 300

@export var minDistToPoint: float = 100
var currPos: Vector3
var layRange: Vector2 = Vector2(2,5)
var currLayTime: float = 2


func _ready():
	currHealth = Health
	setup()
	currPos = pickPoint(circleRadius)

func _physics_process(delta):
	if System_Global.GamePaused:
		return
	turnFollowPoint(player.position + currPos)
	flyToPoint(delta)

var spawnTimer = 0
func _process(delta):
	if System_Global.GamePaused:
		return
	tryFixShield(delta)
	spawnTimer += delta
	if position.distance_to(player.position + currPos) <= minDistToPoint:
		currPos = pickPoint(circleRadius)
		currLayTime = randf_range(layRange.x, layRange.y)
		trySpawnMine(100)
	elif spawnTimer >= currLayTime:
		spawnTimer = 0
		trySpawnMine(100)

func trySpawnMine(chance):
	if randf_range(0, 100) <= chance:
		var newMine = mineScene.instantiate()
		newMine.position = position
		Main.add_child(newMine)

#Get a point in a sphere with x radius
func pickPoint(radius):
	var d = 0.0
	var pos = Vector3.ZERO
	while true:
		pos.x = randf() * 2.0 - 1.0
		pos.y = randf() * 2.0 - 1.0
		pos.z = randf() * 2.0 - 1.0
		d = pos.x*pos.x + pos.y*pos.y + pos.z*pos.z
		if d <= 1.0:
			break
	return pos * radius


func _on_visible_on_screen_notifier_3d_screen_entered():
	isVisible = true
	pass # Replace with function body.


func _on_visible_on_screen_notifier_3d_screen_exited():
	isVisible = false
	pass # Replace with function body.
