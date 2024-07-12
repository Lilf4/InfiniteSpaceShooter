extends PanelContainer

@onready var TimeLabel: Label = $Label
@onready var ChildTimer: Timer = find_child("Timer")
var timeToStart: int = 0

func _process(_delta):
	TimeLabel.text = str("Wave starts in:\r\n", timeToStart)

func startWave(time: int):
	self.visible = true
	timeToStart = time
	ChildTimer.start()

signal WaveStart
func _on_timer_timeout():
	if System_Global.GamePaused:
		return
	timeToStart -= 1
	if timeToStart <= 0:
		ChildTimer.stop()
		WaveStart.emit()
		self.visible = false
	print(timeToStart)
