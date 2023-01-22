extends AudioStreamPlayer

var time = 0
func _process(delta):
	time = (time + delta)
	if time > 12.8: time -= 12.8
