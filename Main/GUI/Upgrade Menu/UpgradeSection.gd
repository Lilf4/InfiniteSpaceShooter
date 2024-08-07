extends Control

@export var UpgradeImage: Texture
@export var UpgradeTextFormat: String = "Upgrade Label"
@export var CurrUpgradeTextFormat: String = "Current {UpgradeVal}, After Upgrade (MATH_FORMAT){{UpgradeVal}+{NextUpgradeAmount}}"
@export var ButtonTextFormat: String = "Upgrade {UpgradePrice} Scrap"
var Global = System_Global

@export var KeyToVarMap: Dictionary = {}

@onready var upgradeTextLabel: Label = find_child("UpgradeNameLabel")
@onready var upgradeDescLabel: Label = find_child("CurrUpgradeInformation")
@onready var upgradeBtn: Button = find_child("Button")

@export var upgradeIdentifier: String
@export var currUpgradeCount: int = 0
@export var upgradeMultipliers: Array = [1.0]

func _ready():
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
	var multToSend = 0
	if currUpgradeCount >= upgradeMultipliers.size():
		multToSend = upgradeMultipliers[upgradeMultipliers.size() - 1]
	else:
		multToSend = upgradeMultipliers[currUpgradeCount]
	UpgradePressed.emit(upgradeIdentifier, multToSend)
	updateText()
