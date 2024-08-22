extends Node

var currID: int = 0
var DEBUG_MODE: bool = false
var EnemyInstances = {}
var ScrapInstances = {}
var GamePaused: bool = false
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

var PlayerPerfTracking = false

func _process(delta):
	if GamePaused or not PlayerPerfTracking:
		return
	
	if PlayerPerformance < 1:
		PlayerPerformance = min(PlayerPerformance + PerfReplenishRate * delta, 1)
		pass
	elif PlayerPerformance > 1:
		PlayerPerformance = max(PlayerPerformance - PerfDrainRate * delta, 1)
		pass
	print(PlayerPerformance)

var PlayerPerformance: float = 1
var PerfReplenishRate: float =  0.02
var PerfDrainRate: float = 0.04

var damageAmountBias: float = 0.08
func playerTookDamage(_amount):
	PlayerPerformance = max(PlayerPerformance - (damageAmountBias + (damageAmountBias * PlayerPerformance - damageAmountBias)), 0)

var playerDamageBias: float = 0.04
func playerDidDamage(_amount):
	PlayerPerformance = min(PlayerPerformance + (playerDamageBias - (playerDamageBias * PlayerPerformance - playerDamageBias)), 2)

var playerKillBias: float = 0.06
func playerKilled(_id):
	PlayerPerformance = min(PlayerPerformance + (playerKillBias - (playerKillBias * PlayerPerformance - playerKillBias)), 2)

var BulletsShot: int = 1
var BulletsHit: int = 1

func getAccuracy():
	return BulletsHit as float / BulletsShot as float
