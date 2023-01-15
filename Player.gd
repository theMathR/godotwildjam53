extends KinematicBody2D

const R_SPEED = 0.05
const SPEED = 200
onready var screen_size = get_viewport_rect().size
var attracted = null

func _physics_process(_delta):
	if Input.is_action_pressed("ui_left"):
		rotate(-R_SPEED)
	if Input.is_action_pressed("ui_right"):
		rotate(R_SPEED)
	if Input.is_action_pressed("ui_up"):
		move_and_slide(Vector2.RIGHT.rotated(rotation)*SPEED)
	elif Input.is_action_pressed("ui_down"):
		move_and_slide(Vector2.LEFT.rotated(rotation)*SPEED)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
