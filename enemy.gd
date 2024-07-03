extends CharacterBody3D

@export var Health = 100

signal enemyDeath

func takeDamage(val):
	Health -= val
	if Health <= 0:
		enemyDeath.emit()
		queue_free()
