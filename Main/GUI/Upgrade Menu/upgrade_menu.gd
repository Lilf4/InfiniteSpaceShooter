extends Control

signal donePressed
func _on_done_pressed():
	donePressed.emit()

signal UpgradeOccured
func _on_upgrade_pressed(ident, mult):
	UpgradeOccured.emit(ident, mult)
