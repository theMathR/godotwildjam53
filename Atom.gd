extends RigidBody2D

onready var player = get_node('../Player')
var in_attraction_area = false
var attached = false
var speed = 0

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Area2D_body_entered(body):
	if body == self: in_attraction_area = true

func _on_Area2D_body_exited(body):
	if body == self: in_attraction_area = false
	if player.attracted == self: player.attracted = null

func _physics_process(delta):
	if in_attraction_area:
		if player.attracted == null: player.attracted = self
		elif (player.position + Vector2.LEFT.rotated(player.rotation)*50 - position).length_squared() < (player.position + Vector2.LEFT.rotated(player.rotation)*50 - player.attracted.position).length_squared():
			player.attracted = self
	if not (in_attraction_area and Input.is_action_pressed("ui_select")):
		speed = linear_velocity.length()

func _integrate_forces(state):
	if in_attraction_area:
		if Input.is_action_pressed("ui_select"):
			if player.attracted == self:
				state.linear_velocity = (player.position + Vector2.LEFT.rotated(player.rotation)*50 - position)*10
				attached = true
		elif attached:
			state.linear_velocity = (position-player.position).normalized()*speed*1.25
			attached = false
