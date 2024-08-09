extends Node

@onready var player = $Player

@onready var input_settings_menu = $GUI/InputSettings
@onready var fpsLabel = $GUI/DebugInfo/VBoxContainer/fpsLabel
@onready var deathScreen = $GUI/DeathScreen
@onready var healthBar = $GUI/PlayElements/HealthBar/Foreground/HealthProgress
@onready var speedLabel = $GUI/PlayElements/MoveDisplay/MarginContainer/HBoxContainer/Label
@onready var ParticleEmitter = $Player/GPUParticles3D
@onready var UpgradeMenu = $GUI/UpgradeMenu

@onready var MainMenu: PackedScene = preload("res://Main/MainMenu.tscn")

var PlayerDead: bool = false
var UpgradeMenuOpen: bool = false

func _ready():
	print("Startup")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta):
	healthBar.value = player.currHealth
	fpsLabel.text = str("FPS: ", Engine.get_frames_per_second())
	speedLabel.text = str("Speed: ", "%.2f" % player.velocity.distance_to(Vector3.ZERO), " kpm")
	if System_Global.GamePaused:
		ParticleEmitter.speed_scale = 0
	else:
		ParticleEmitter.speed_scale = 1

func _unhandled_input(event):
	if event.is_action_pressed("pause") and !PlayerDead and !UpgradeMenuOpen:
		System_Global.GamePaused = !System_Global.GamePaused
		if System_Global.GamePaused:
			input_settings_menu.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			input_settings_menu.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().root.get_viewport().set_input_as_handled()

func PlayerDeath():
	System_Global.GamePaused = true
	System_Global.EnemyInstances.clear()
	PlayerDead = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	deathScreen.visible = true

func Retry():
	System_Global.GamePaused = false
	System_Global.ResetGameValues()
	get_tree().reload_current_scene()

func Quit():
	System_Global.GamePaused = false
	get_tree().change_scene_to_file("res://Main/MainMenu.tscn")

func OpenUpgrades():
	for scrap in System_Global.ScrapInstances:
		print(scrap)
		scrap._on_area_3d_body_entered(player)
	System_Global.GamePaused = true
	UpgradeMenuOpen = true
	showMouse()
	UpgradeMenu.show()

func CloseUpgrades():
	System_Global.GamePaused = false
	UpgradeMenuOpen = false
	hideMouse()
	UpgradeMenu.hide()

func hideMouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func showMouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_upgrade_menu_upgrade_occured(ident, mult):
	mult -= 1
	match ident:
		"ShipRepair":
			player.currHealth = player.Health
		"EndOfWaveHeal":
			System_Global.endRepairMultiplier += mult
		"FireRate":
			System_Global.fireRateMultiplier += mult
		"DamageUp":
			System_Global.damageMultiplier += mult
		"Shield":
			print("Tried to upgrade shield")
