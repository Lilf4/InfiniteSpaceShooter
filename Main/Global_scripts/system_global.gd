extends Node

var currID: int = 0
var DEBUG_MODE = false
var EnemyInstances = {}

func GET_NEWID():
	var returnVal = currID
	currID += 1
	return returnVal
