extends Node3D

func _on_area_3d_body_entered(body):
	System_Global.Scrap += randi_range(1, 3)
	queue_free()
