extends Node3D

@export var maxDist: float = 500
var localScale: float = 100

@onready var Player = find_parent("Main").find_child("Player")
@onready var Pivot = $Pivot
@onready var EnemyDot = preload("res://Main/GUI/enemy_dot.tscn")
@onready var Cam = $Pivot/Camera3D
@onready var HorizontalVis = $Pivot/HorizontalVis
var enemies = {}
var enemyLines = {}
func _ready():
	pass

func _process(_delta):
	if System_Global.GamePaused:
		return
	Pivot.rotation = Player.rotation
	updateDotPos()

func updateDotPos():
	for enemy in enemies:
		var enemyInstance = System_Global.EnemyInstances[enemy]
		var dirFromPlayer = Player.global_position.direction_to(enemyInstance.global_position)
		var distFromPlayer = Player.global_position.distance_to(enemyInstance.global_position)
		var line: Draw3D = enemyLines[enemy]
		line.clear()
		if distFromPlayer > maxDist:
			enemies[enemy].visible = false
			continue
		else:
			enemies[enemy].visible = true
			
			var scaledDist = (localScale * 0.5 - 0) * ((distFromPlayer - enemies[enemy].scale.x - 0) / (maxDist - 0)) + 0
			
			enemies[enemy].position = dirFromPlayer * scaledDist
			
			var object_position = enemies[enemy].global_transform.origin
			var plane_position = Pivot.global_transform.origin
			
			var plane_normal = Pivot.global_transform.basis.y
			
			var plane_to_object = object_position - plane_position
			
			var distance_to_plane = plane_normal.dot(plane_to_object)
			var closest_point_on_plane = object_position - plane_normal * distance_to_plane
			
			line.draw_line([closest_point_on_plane, enemies[enemy].global_position], Color.RED)


func _on_wave_spawner_enemy_spawned(id):
	if not enemies.has(id):
			var NewEnemyDot = EnemyDot.instantiate()
			enemies[id] = NewEnemyDot
			enemyLines[id] = Draw3D.new()
			add_child(enemyLines[id])
			add_child(NewEnemyDot)


func _on_wave_spawner_enemy_dead(id):
	if not System_Global.EnemyInstances.has(id):
			var enemyDotInstance: MeshInstance3D = enemies[id]
			var enemyLineInstance: Draw3D = enemyLines[id]
			enemies.erase(id)
			enemyLines.erase(id)
			remove_child(enemyLineInstance)
			remove_child(enemyDotInstance)
