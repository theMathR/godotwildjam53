extends KinematicBody2D

const R_SPEED = 0.1
const SPEED = 300
var health = 100
onready var screen_size = get_viewport_rect().size
var attracted = null
var damage_cooldown = false

func _physics_process(_delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		rotate(-R_SPEED)
	elif Input.is_action_pressed("move_right"):
		rotate(R_SPEED)
	if Input.is_action_pressed("move_up"):
		velocity = Vector2.LEFT.rotated(rotation)*SPEED
	elif Input.is_action_pressed("move_down"):
		velocity = Vector2.RIGHT.rotated(rotation)*SPEED
	if velocity:
		move_and_slide(velocity)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 30, screen_size.y-33)
	
	if Input.is_action_pressed("ui_accept") and Input.is_action_pressed("ui_select"):
		if attracted:
			var formula = attracted.get_molecule()
			if formula in get_parent().goal_molecules.keys() and get_parent().goal_molecules[formula]:
				attracted.do_remove()
				get_parent().send_molecule(formula)
				$"../Levelup".play(0.33)
	
	$Ray.visible = Input.is_action_pressed("ui_select")
	if Save.flickering: $Ray.modulate = Color.white if randi() % 2 else Color.gray
	
	if damage_cooldown and Save.flickering: visible = int($DamageCooldown.time_left * 8) % 2
	else: visible = true
	 
	if $AudioStreamPlayer.playing != (Input.is_action_pressed("ui_select") or velocity):
		$AudioStreamPlayer.playing = Input.is_action_pressed("ui_select") or velocity

func damage(d):
	if damage_cooldown: return
	health -= d
	$DamageCooldown.start()
	damage_cooldown = true
	health = max(0, health)
	if health == 0:
		get_node("../LoseMenu").show()
		get_tree().paused = true
	$Hurt.play()
	get_node("../TopBar/HBoxContainer/Health").text = "Health: " + str(health) + "%"

func _on_DamageCooldown_timeout():
	damage_cooldown = false
