extends Label

func _process(_delta):
	text = str("Accuracy: ", "%3d" % (System_Global.getAccuracy() * 100), "%")
