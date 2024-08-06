extends Control

@export var UpgradeImage: Texture
@export var UpgradeTextFormat: String = "Upgrade Label"
@export var CurrUpgradeTextFormat: String = "Current {UpgradeVal}, After next Upgrade (MATH_FORMART_ADD_FLOAT){{UpgradeVal},{NextUpgradeAmount}}"
@export var ButtonTextFormat: String = "Upgrade {UpgradePrice} Scrap"

@onready var upgradeTextLabel: Label = find_child("UpgradeNameLabel")

func _ready():
	upgradeTextLabel.text = ProcessFormartting(UpgradeTextFormat)

func _process(delta):
	pass

func ConvertMappings(input):
	var output: String
	return output

func ProcessLogicalFormart():
	pass

func ProcessFormartting(input: String):
	var output = ConvertMappings(input)
	return output
