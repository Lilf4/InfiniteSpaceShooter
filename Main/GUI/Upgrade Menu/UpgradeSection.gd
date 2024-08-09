extends Control

var Global = System_Global

@export_category("Formatting")
@export var UpgradeImage: Texture
@export_multiline var UpgradeTextFormat: String
@export_multiline var CurrUpgradeTextFormat: String
@export_multiline var ButtonTextFormat: String

@export var KeyToVarMap: Dictionary = {}

@onready var textureRect: TextureRect = find_child("TextureRect")
@onready var upgradeTextLabel: Label = find_child("UpgradeNameLabel")
@onready var upgradeDescLabel: Label = find_child("CurrUpgradeInformation")
@onready var upgradeBtn: Button = find_child("Button")

@export_category("Upgrade variables")
@export var AdditiveMultipliers: bool = true
@export var upgradeIdentifier: String
@export var maxUpgrades: int = 0
@export var currUpgradeCount: int = 0
@export var upgradeMultipliers: Array = [1.0]

@export var baseCost: int = 0
var costMultiplier: float = 1.0
@export var costMultipliers: Array = [1.0]

func _ready():
	costMultiplier = costMultipliers[0]
	textureRect.texture = UpgradeImage
	updateText()

func updateText():
	upgradeTextLabel.text = ProcessFormartting(UpgradeTextFormat)
	upgradeDescLabel.text = ProcessFormartting(CurrUpgradeTextFormat)
	upgradeBtn.text = ProcessFormartting(ButtonTextFormat)

func ConvertMappings(input):
	var output: String = input
	for Key in KeyToVarMap:
		if not output.contains(str("{", Key, "}")):
			continue
		var KeyValue
		if (KeyToVarMap[Key] as String).begins_with(":"):
			KeyValue = (KeyToVarMap[Key] as String).erase(0,1)
		else:
			var VariablePath: String = KeyToVarMap[Key] as String
			var SplitPath = VariablePath.split(".")
			var LastIterateResult
			var firstDone: bool = false
			for part in SplitPath:
				var temp
				if firstDone:
					temp = LastIterateResult.get(part)
				else:
					temp = get(part)
					firstDone = true
				if temp is Callable:
					temp = temp.call()
				LastIterateResult = temp
			KeyValue = LastIterateResult
		output = output.replace(str("{", Key, "}"), str(KeyValue))
	return output

func ProcessLogicalFormart(input: String):
	var output = input
	var noLogicToProcess: bool = false
	while(not noLogicToProcess):
		if output.contains("(MATH_FORMAT)"):
			var startIndex: int = output.find("(MATH_FORMAT)")
			var startOffset: int = 13
			var index: int = startIndex + startOffset
			var endIndex: int
			
			var hasReturnedToOuter: bool = false
			var bodies: Array
			var currDepth: int = 0
			
			while(not hasReturnedToOuter):
				if index > output.length():
					push_error("Missing closing tag")
				var currChar = output[index]
				if currChar == "}" and currDepth == 0:
					endIndex = index
					hasReturnedToOuter = true
				elif currChar == "(":
					currDepth += 1
				elif currChar == ")":
					currDepth -= 1
				index += 1
			var exp = Expression.new()
			exp.parse(output.substr(startIndex + startOffset + 1, endIndex - (startIndex + startOffset)))
			var result = exp.execute()
			output = output.replace(output.substr(startIndex, endIndex - (startIndex) + 1), str(result))
		else:
			noLogicToProcess = true
	return output

func ProcessFormartting(input: String):
	var output = ConvertMappings(input)
	output = ProcessLogicalFormart(output)
	return output

signal UpgradePressed
func _on_upgrade_pressed():
	#If has enough scrap
	var cost = baseCost * costMultiplier
	if System_Global.Scrap >= cost and (maxUpgrades == 0 or maxUpgrades > currUpgradeCount):
		System_Global.Scrap -= cost
	else:
		return
	
	var multiplier: float
	if currUpgradeCount >= costMultipliers.size() - 1:
		multiplier = costMultipliers[costMultipliers.size() - 1]
	else:
		multiplier = costMultipliers[currUpgradeCount + 1]
	
	if AdditiveMultipliers:
		costMultiplier += multiplier
	else:
		costMultiplier = multiplier
	
	var multToSend = 0
	currUpgradeCount += 1
	if currUpgradeCount >= upgradeMultipliers.size():
		multToSend = upgradeMultipliers[upgradeMultipliers.size() - 1]
	else:
		multToSend = upgradeMultipliers[currUpgradeCount]
	UpgradePressed.emit(upgradeIdentifier, multToSend)
	updateText()

func nextMultiplier():
	var mult = 0
	if currUpgradeCount >= upgradeMultipliers.size() - 1:
		mult = upgradeMultipliers[upgradeMultipliers.size() - 1]
	else:
		mult = upgradeMultipliers[currUpgradeCount + 1]
	return mult - 1

func GetCost():
	return baseCost * costMultiplier
