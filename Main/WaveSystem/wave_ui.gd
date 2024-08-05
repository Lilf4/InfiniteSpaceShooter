extends Control

#Contains functions to interact with elements under the WaveUI scene
#Aswell as emitting important signals further for outside scripts to connect to

@onready var WaveStartTimerUI = $WaveStartTimer
@onready var WaveDisplay = $PanelContainer/Label
signal WaveStarted

func wave_start():
	WaveStarted.emit()

func StartWave(TimeToStart: int):
	WaveStartTimerUI.startWave(TimeToStart)

func SetWaveCount(waveCount: int):
	WaveDisplay.text = str("Wave: ", waveCount)


func _on_wave_spawner_enemy_dead():
	pass # Replace with function body.
