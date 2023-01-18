extends Node2D

export(PackedScene) var atom_scene
onready var atoms_parent = get_node("Atoms")

var level = 1
var goal_molecules = {}

signal level_ended

const levels = [0,
	[[0,0,0,0,1], [50, 50, 50, 501], {'H2':3}], # Level 1
	[[5], [50, 50, 0, 501], {'C':2}]  # Level 2
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
	randomize()
	goal_molecules = levels[level][2].duplicate()
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
		level += 1
		$TopBar/HBoxContainer/Level.text = "Level: " + str(level)
		for m in $BottomBar/HBoxContainer/HBoxContainer.get_children():
			m.queue_free()
		emit_signal("level_ended")
		goal_molecules = levels[level][2].duplicate()
		for m in goal_molecules.keys():
			var label = Label.new()
			label.text = m + ": " + str(goal_molecules[m])
			label.name = m
			label.align = true
			label.valign = true
			label.size_flags_horizontal = Label.SIZE_EXPAND_FILL
			$BottomBar/HBoxContainer/HBoxContainer.add_child(label)

func _on_AtomTimer_timeout():
	# Create a new instance of the atom scene.
	var atom = atom_scene.instance()

	# Choose a random location on Path2D.
	var atom_spawn_location = get_node("Path2D/PathFollow2D")
	atom_spawn_location.offset = randi()

	# Set the atom's direction perpendicular to the path direction.
	var direction = atom_spawn_location.rotation + PI / 2

	# Set the atom's position to a random location.
	atom.position = atom_spawn_location.position
	
	# Set the atom's type and sprite
	atom.atom_type = levels[level][0][randi() % len(levels[level][0])]
	atom.get_node('CollisionShape2D/Sprite').set_texture(atom_sprites[atom.atom_type])

	# Choose the velocity for the atom.
	var velocity = Vector2.RIGHT * levels[level][1][randi() % len(levels[level][1])]
	atom.linear_velocity = velocity.rotated(direction)
	
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
