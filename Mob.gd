extends CharacterBody3D

@export var min_speed = 6

@export var max_speed = 10

func _physics_process(delta):
	move_and_slide()

func init(start_position, player_position):
	look_at_from_position(Vector3(start_position.x, 0, start_position.z), Vector3(player_position.x, 0, start_position.z), Vector3.UP)
	
	rotate_y(randf_range(-PI / 4, PI / 4))
	
	var random_speed = randi_range(min_speed, max_speed)
	
	velocity = Vector3.FORWARD * random_speed
	
	velocity = velocity.rotated(Vector3.UP, rotation.y)

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()

signal squashed
func squash():
	squashed.emit()
	queue_free()
