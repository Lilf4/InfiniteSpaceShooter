extends Control

@onready var Base: Control = $PanelContainer/VBoxContainer/Base
@onready var Selector: Control = $PanelContainer/VBoxContainer/SettingsSelector

var defaultBaseVisible: bool = true
var defaultSelectorVisibile: bool = false

func reset():
	if defaultBaseVisible:
		Base.show()
	else:
		Base.hide()
	
	if defaultSelectorVisibile:
		Selector.show()
	else:
		Selector.hide()

signal resumed
func _on_resume_pressed():
	reset()
	hide()
	resumed.emit()

func _on_settings_pressed():
	Base.hide()
	Selector.show()

signal doRestart
func _on_restart_pressed():
	reset()
	hide()
	doRestart.emit()

signal doQuitToMenu
func _on_quit_to_menu_pressed():
	doQuitToMenu.emit()

signal openKeybinds
func _on_keybinds_pressed():
	hide()
	openKeybinds.emit()

signal openGeneral
func _on_general_pressed():
	hide()
	openGeneral.emit()

func _on_SecondSettingsback_pressed():
	Selector.hide()
	Base.show()
