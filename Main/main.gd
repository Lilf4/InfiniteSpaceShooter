extends Node

@onready var player = $Player

@onready var input_settings_menu = $GUI/InputSettings
@onready var fpsLabel = $GUI/VBoxContainer/fpsLabel
@onready var deathScreen = $GUI/DeathScreen
@onready var healthBar = $GUI/PlayElements/HealthBar/Foreground/HealthProgress

var PlayerDead: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta):
	healthBar.value = player.Health
	fpsLabel.text = str("FPS: ", Engine.get_frames_per_second())
	

func _unhandled_input(event):
	if event.is_action_pressed("pause") and !PlayerDead:
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
	PlayerDead = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	deathScreen.visible = true

func Retry():
	get_tree().reload_current_scene()
	System_Global.GamePaused = false

func Quit():
	get_tree().quit()
