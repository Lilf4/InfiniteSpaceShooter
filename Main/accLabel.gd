extends Label

func _process(_delta):
	text = str("Accuracy: ", "%s" % (System_Global.getAccuracy() * 100), "%")
