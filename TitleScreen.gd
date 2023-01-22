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

func _on_AtomTimer_timeout():
	# Create a new instance of the atom scene.
	var atom = atom_scene.instance()

	# Choose a random location on Path2D.
	var atom_spawn_location = get_node("Path2D/PathFollow2D")
	atom_spawn_location.offset = randi()
	atom_spawn_location.offset = randi()

	# Set the atom's direction perpendicular to the path direction.
	var direction = atom_spawn_location.rotation + PI / 2

	# Set the atom's position to a random location.
	atom.position = atom_spawn_location.position
	
	# Set the atom's type and sprite
	atom.atom_type = randi() % 22
	atom.get_node('CollisionShape2D/Sprite').set_texture(atom_sprites[atom.atom_type])

	# Choose the velocity for the atom.
	var velocity = Vector2.RIGHT * (200 + 100 * (randi() % 3))
	atom.linear_velocity = velocity.rotated(direction)

	# Spawn the atom by adding it to the Main scene.
	atoms_parent.add_child(atom)

func _ready():
	$Panel/Settings/Flickering/CheckBox.pressed = Save.flickering
	$Panel/Settings/Volume/HScrollBar.value = Save.volume
	$Panel/Settings/SEVolume/HScrollBar.value = Save.sevolume
	if Save.level == 1:
		$Panel/Main/Continue.hide()
	
	if Save.start:
		Save.start = false
	else:
		$Click.play()

func _on_Continue_pressed():
	get_tree().change_scene("res://World.tscn")


func _on_New_pressed():
	Save.level = 1
	get_tree().change_scene("res://World.tscn")


func _on_Credits_pressed():
	$Panel/Main.hide()
	$Panel/Credits.show()
	
	$Click.play()


func _on_Back_pressed():
	$Panel/Credits.hide()
	$Panel/Settings.hide()
	$Panel/Tutorial.hide()
	$Panel/Main.show()
	$Click.play()


func _on_Settings_pressed():
	$Panel/Main.hide()
	$Panel/Settings.show()
	$Click.play()


func _on_Button_click_pls():
	$Click.play()


func _on_CheckBox_toggled(button_pressed):
	Save.flickering = button_pressed
	if not Save.start:
		$Click.play()


func _on_Volume_value_changed(value):
	Save.volume = value
	#var bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(2, value*6/10-60)


func _on_SFXVolume_value_changed(value):
	Save.sevolume = value
	AudioServer.set_bus_volume_db(1, value*6/10-60)


func _on_Sandbox_pressed():
	get_tree().change_scene("res://Free.tscn")


func _on_Tutorial_pressed():
	$Panel/Main.hide()
	$Panel/Tutorial.show()
	$Click.play()
