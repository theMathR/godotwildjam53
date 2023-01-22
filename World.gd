extends Node

export(PackedScene) var atom_scene
onready var atoms_parent = get_node("Atoms")

var phase = 0
var goal_molecules = {}

signal level_ended

const levels = [0,
	[{'NaCl':3}, [[1, 1, [10, 16], [200]]]], # Level 1
	[{'BF3':1, 'Cl2Ca': 1}, [ [0.5,5, [4, 8, 8, 8, 8, 4, 9], [600, 300, 300, 100]], [0.5, 5, [[10,16], 18], [300, 200]] ]],
	[{'CHN':2, 'CHNK':1}, [[1, 4, [[0, 5], 6], [200, 300]], [1, 2, [17], [200]]]],
	[{'H2O': 2}, [[0.5, 100, [22, [0, 0, 15], 7], [300, 400, 500]]]],
	[{'HLiO':2, 'H2':1}, [[0.5, 2, [[0,0,7]], [400]], [0.5, 2, [2, 1], [600]]]],
	[{'P4':1, 'O2Si': 1}, [[0.75, 3, [22, 14, 14, 14], [400]], [0.75, 3, [[7, 7], 13], [400]]]],
	[{'NaCl':2, 'H2O': 2}, [ [2, 6, [1, [10, 7, 0]], [200, 200, 600]], [2, 6, [1, [0, 16]], [200, 200, 600]] ]],
	[{'CO2': 1, 'CH4':1}, [ [1, 1, [5], [200, 501]], [1, 2, [0, 7], [300, 200, 200, 600]] ]],
	[{'CW':2, 'O2W':2}, [[0.5, 100, [[7, 7], 19, 5], [600]]]],
	[{'H': 1}, [[0.375, 15, [1, 1, 1, 22, 22, 21], [750, 750, 400]], [1, 100, [0], [100]]]]
]

const atom_sprites = [
	preload("res://assets/1.png"),
	preload("res://assets/2.png"),
	preload("res://assets/3.png"),
	preload("res://assets/4.png"),
	preload("res://assets/5.png"),
	preload("res://assets/6.png"),
	preload("res://assets/7.png"),
	preload("res://assets/8.png"),
	preload("res://assets/9.png"),
	preload("res://assets/10.png"),
	preload("res://assets/11.png"),
	preload("res://assets/12.png"),
	preload("res://assets/13.png"),
	preload("res://assets/14.png"),
	preload("res://assets/15.png"),
	preload("res://assets/16.png"),
	preload("res://assets/17.png"),
	preload("res://assets/18.png"),
	preload("res://assets/19.png"),
	preload("res://assets/20.png"),
	preload("res://assets/21.png"),
	preload("res://assets/22.png"),
	preload("res://assets/23.png")
]

func _ready():
	$Drums.play(Music.time-0.5)
	randomize()
	$TopBar/HBoxContainer/Level.text = "Level " + str(Save.level)
	goal_molecules = levels[Save.level][0].duplicate()
	$AtomTimer.wait_time = levels[Save.level][1][phase][0]
	$PhaseTimer.wait_time = levels[Save.level][1][phase][1]
	$AtomTimer.start()
	$PhaseTimer.start()
	for m in goal_molecules.keys():
		var label = Label.new()
		label.text = m + ": " + str(goal_molecules[m])
		label.name = m
		label.align = true
		label.valign = true
		label.size_flags_horizontal = Label.SIZE_EXPAND_FILL
		$BottomBar/HBoxContainer/HBoxContainer.add_child(label)

func send_molecule(formula):
	goal_molecules[formula] -= 1
	get_node("BottomBar/HBoxContainer/HBoxContainer/"+formula).text = formula + ": " + str(goal_molecules[formula])
	if goal_molecules.values().count(0) == len(goal_molecules):
		$Levelup.play()
		if Save.level + 1 == len(levels):
			get_tree().paused = true
			$WinMenu.show()
			return
		Save.level += 1
		$TopBar/HBoxContainer/Level.text = "Level " + str(Save.level)
		for m in $BottomBar/HBoxContainer/HBoxContainer.get_children():
			m.name = "h"
			m.queue_free()
		emit_signal("level_ended")
		goal_molecules = levels[Save.level][0].duplicate()
		for m in goal_molecules.keys():
			var label = Label.new()
			label.text = m + ": " + str(goal_molecules[m])
			label.name = m
			label.align = true
			label.valign = true
			label.size_flags_horizontal = Label.SIZE_EXPAND_FILL
			$BottomBar/HBoxContainer/HBoxContainer.add_child(label)
		phase = 0
		$AtomTimer.stop()
		$PhaseTimer.stop()
		$AtomTimer.wait_time = levels[Save.level][1][phase][0]
		$PhaseTimer.wait_time = levels[Save.level][1][phase][1]
		$AtomTimer.start()
		$PhaseTimer.start()
		$Player.health = 100

func _on_AtomTimer_timeout():
	var molecule = levels[Save.level][1][phase][2][randi() % len(levels[Save.level][1][phase][2])]
	
	# Choose a random location on Path2D.
	var atom_spawn_location = get_node("Path2D/PathFollow2D")
	atom_spawn_location.offset = randi()
	
	# Set the atom's direction perpendicular to the path direction.
	var direction = atom_spawn_location.rotation + PI / 2

	# Choose the velocity for the atom.
	var velocity = Vector2.RIGHT * levels[Save.level][1][phase][3][randi() % len(levels[Save.level][1][phase][3])]
	velocity = velocity.rotated(direction)
	
	if molecule is int: molecule = [molecule]
	for m in molecule:
		# Create a new instance of the atom scene.
		var atom = atom_scene.instance()

		# Set the atom's position to a random location.
		atom.position = atom_spawn_location.position
		atom.linear_velocity = velocity
		
		# Set the atom's type and sprite
		atom.atom_type = m
		atom.get_node('CollisionShape2D/Sprite').set_texture(atom_sprites[atom.atom_type])
		
		# Link the attraction area of the player to the atom
		$Player/Area2D.connect("body_entered", atom, "_on_Area2D_body_entered")
		$Player/Area2D.connect("body_exited", atom, "_on_Area2D_body_exited")
		connect("level_ended", atom, "queue_free")

		# Spawn the atom by adding it to the Main scene.
		atoms_parent.add_child(atom)

func _on_TemperatureTimer_timeout():
	var temperature = 0
	for atom in $Atoms.get_children():
		temperature += atom.linear_velocity.length()
	if temperature > 0: temperature /= $Atoms.get_child_count() * 10
	$TopBar/HBoxContainer/Temperature.text = "Temperature: " + str(round(temperature)) + "°H"


func _on_PhaseTimer_timeout():
	phase = (phase+1) % len(levels[Save.level][1])
	$AtomTimer.stop()
	$PhaseTimer.stop()
	$AtomTimer.wait_time = levels[Save.level][1][phase][0]
	$PhaseTimer.wait_time = levels[Save.level][1][phase][1]
	$AtomTimer.start()
	$PhaseTimer.start()

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		$Drums.play(Music.time-0.5)
		get_tree().paused = true
		$PauseMenu.show()
		$Click.play()
