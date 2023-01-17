extends KinematicBody2D

const R_SPEED = 0.10
const SPEED = 300
onready var screen_size = get_viewport_rect().size
var attracted = null

func _physics_process(_delta):
	if Input.is_action_pressed("move_left"):
		rotate(-R_SPEED)
	if Input.is_action_pressed("move_right"):
		rotate(R_SPEED)
	if Input.is_action_pressed("move_up"):
		move_and_slide(Vector2.RIGHT.rotated(rotation)*SPEED)
	elif Input.is_action_pressed("move_down"):
		move_and_slide(Vector2.LEFT.rotated(rotation)*SPEED)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
