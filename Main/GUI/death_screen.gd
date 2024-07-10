extends Control

signal Retry
signal Quit

func _on_retry_btn_pressed():
	Retry.emit()


func _on_quit_btn_pressed():
	Quit.emit()
