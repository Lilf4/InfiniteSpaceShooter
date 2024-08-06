extends Control

signal donePressed
func _on_done_pressed():
	donePressed.emit()
