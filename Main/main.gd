extends Node

@onready var input_settings_menu = $GUI/InputSettings
@onready var fpsLabel = $GUI/VBoxContainer/fpsLabel
var game_paused = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta):
	fpsLabel.text = str("FPS: ", Engine.get_frames_per_second())

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		game_paused = !game_paused
		if game_paused:
			input_settings_menu.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			input_settings_menu.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().root.get_viewport().set_input_as_handled()