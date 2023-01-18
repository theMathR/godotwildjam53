extends KinematicBody2D

const R_SPEED = 0.10
const SPEED = 300
var health = 100
onready var screen_size = get_viewport_rect().size
var attracted = null
var damage_cooldown = false

func _physics_process(_delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		rotate(-R_SPEED)
	if Input.is_action_pressed("move_right"):
		rotate(R_SPEED)
	if Input.is_action_pressed("move_up"):
		velocity = Vector2.RIGHT.rotated(rotation)*SPEED
	elif Input.is_action_pressed("move_down"):
		velocity = Vector2.LEFT.rotated(rotation)*SPEED
	if velocity:
		move_and_slide(velocity)
		# TODO: Sounds
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if Input.is_action_pressed("ui_accept"):
		if attracted:
			var formula = attracted.get_molecule()
			if formula in get_parent().goal_molecules.keys() and get_parent().goal_molecules[formula]:
				attracted.do_remove()
				get_parent().send_molecule(formula)
	
	$Ray.visible = Input.is_action_pressed("ui_select")
	#$Ray.modulate = Color.black if randi() % 2 else Color.white

func damage(d):
	if damage_cooldown: return
	health -= d
	$DamageCooldown.start()
	damage_cooldown = true
	get_node("../TopBar/HBoxContainer/Health").text = "Health: " + str(health) + "%"

func _on_DamageCooldown_timeout():
	damage_cooldown = false
