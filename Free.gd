extends Node

export(PackedScene) var atom_scene
onready var atoms_parent = get_node("Atoms")

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

func _on_AtomTimer_timeout():
	
	# Choose a random location on Path2D.
	var atom_spawn_location = get_node("Path2D/PathFollow2D")
	atom_spawn_location.offset = randi()
	
	# Set the atom's direction perpendicular to the path direction.
	var direction = atom_spawn_location.rotation + PI / 2

	# Choose the velocity for the atom.
	var velocity = Vector2.RIGHT * ( 200 + 100*randi() % 6)
	velocity = velocity.rotated(direction)

	# Create a new instance of the atom scene.
	var atom = atom_scene.instance()

	# Set the atom's position to a random location.
	atom.position = atom_spawn_location.position
	atom.linear_velocity = velocity
	
	# Set the atom's type and sprite
	atom.atom_type = randi()%23
	atom.get_node('CollisionShape2D/Sprite').set_texture(atom_sprites[atom.atom_type])
	
	# Link the attraction area of the player to the atom
	$Player/Area2D.connect("body_entered", atom, "_on_Area2D_body_entered")
	$Player/Area2D.connect("body_exited", atom, "_on_Area2D_body_exited")

	# Spawn the atom by adding it to the Main scene.
	atoms_parent.add_child(atom)

func _on_TemperatureTimer_timeout():
	var temperature = 0
	for atom in $Atoms.get_children():
		temperature += atom.linear_velocity.length()
	if temperature > 0: temperature /= $Atoms.get_child_count() * 10
	$TopBar/HBoxContainer/Temperature.text = "Temperature: " + str(round(temperature)) + "°H"

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		$Drums.play(Music.time-0.5)
		get_tree().paused = true
		$PauseMenu.show()
		$Click.play()
