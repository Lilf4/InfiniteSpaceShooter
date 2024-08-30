extends Control

@onready var ShieldProgressBar: TextureProgressBar = $Panel/ShieldProgressBar
@onready var HealthProgressBar: TextureProgressBar = $Panel/ShieldProgressBar/HealthProgressBar

var maxHealth: float = 0
var currHealth: float = 0

var maxShield: float = 0
var currShield: float = 0


func setMaxShield(val):
	maxShield = val
	updateVisuals()

func setCurrShield(val):
	currShield = val
	updateVisuals()

func setMaxHealth(val):
	maxHealth = val
	updateVisuals()	

func setCurrHealth(val):
	currHealth = val
	updateVisuals()

func updateVisuals():
	ShieldProgressBar.value = 70.0 if maxShield == 0 else currShield / maxShield * 100
	HealthProgressBar.value = 0.0 if maxHealth == 0 else currHealth / maxHealth * 100
