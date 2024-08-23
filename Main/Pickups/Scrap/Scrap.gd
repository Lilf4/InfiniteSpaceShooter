extends Node3D

@export var lifetime: float = 10
@export var pickupAmountRange: Vector2 = Vector2(1, 3)

var GUID: int
func _ready():
	GUID = System_Global.GET_NEWID()
	System_Global.ScrapInstances[GUID] = self

var timeAlive = 0
func _process(delta):
	timeAlive += delta
	if timeAlive >= lifetime:
		eraseSelf()

func _on_area_3d_body_entered(_body):
	pickedUp()

func pickedUp():
	System_Global.Scrap += randi_range(pickupAmountRange.x as int, pickupAmountRange.y as int)
	eraseSelf()

func eraseSelf():
	System_Global.ScrapInstances.erase(GUID)
	queue_free()
