extends MeshInstance3D

@export var removeDist: float = 500
@onready var Player = find_parent("Main").find_child("Player")

func _process(delta: float) -> void:
	return
	if(Player != null):
		if global_position.distance_to(Player.position) > 500:
			queue_free()
