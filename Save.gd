extends Node

var level = 1
var flickering = true
var start = true
var controls = {}
var volume = 100
var sevolume = 100

func _enter_tree():
	var save_game = File.new()
	if not save_game.file_exists("user://save.json"):
		return
	save_game.open('user://save.json', File.READ)
	var save = parse_json(save_game.get_line())
	level = save["level"]
	flickering = save["flickering"]
	controls = save["controls"]
	volume = save["volume"]
	sevolume = save["sevolume"]
	save_game.close()

func _exit_tree():
	var save_game = File.new()
	save_game.open('user://save.json', File.WRITE)
	var save = {"level": level, "flickering": flickering, "controls": controls, "volume": volume, "sevolume": sevolume}
	save_game.store_line(to_json(save))
	save_game.close()
