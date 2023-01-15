extends Node2D

export(PackedScene) var atom_scene

func _ready():
	randomize()
	$AtomTimer.start()

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

	# Choose the velocity for the atom.
	var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	atom.linear_velocity = velocity.rotated(direction)
	
	# Link the attraction area of the player to the atom
	$Player/Area2D.connect("body_entered", atom, "_on_Area2D_body_entered")
	$Player/Area2D.connect("body_exited", atom, "_on_Area2D_body_exited")

	# Spawn the atom by adding it to the Main scene.
	add_child(atom)
