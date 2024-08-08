extends Node

var currID: int = 0
var DEBUG_MODE = false
var EnemyInstances = {}
var GamePaused = false
var Scrap: int = 0

#Upgrades Section
var baseDamage = 10
var baseDamageMultiplier = 1.0
var damageMultiplier = 1.0

var baseFireRate = 5
var baseFireRateMultiplier = 1.0
var fireRateMultiplier = 1.0

var baseShield = 10
var baseShieldMultiplier = 0.0
var shieldMultiplier = 0.0

var baseEndRepair = 25
var baseEndRepairMultiplier = 1.0
var endRepairMultiplier = 1.0
#End

func GET_NEWID():
	var returnVal = currID
	currID += 1
	return returnVal

func ResetGameValues():
	Scrap = 0
	damageMultiplier = baseDamageMultiplier
	fireRateMultiplier = baseFireRateMultiplier
	shieldMultiplier = baseShieldMultiplier
	endRepairMultiplier = baseEndRepairMultiplier
