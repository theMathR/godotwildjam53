extends RigidBody2D

onready var player = get_node('../Player')
var in_attraction_area = false
var attached = false
var speed = 0
var connected_to = {}
var got_connected_to = []

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Area2D_body_entered(body):
	if body == self: in_attraction_area = true

func _on_Area2D_body_exited(body):
	if body == self: in_attraction_area = false
	if player.attracted == self: player.attracted = null

func _physics_process(_delta):
	if in_attraction_area:
		if player.attracted == null: player.attracted = self
		elif (player.position + Vector2.LEFT.rotated(player.rotation)*50 - position).length_squared() < (player.position + Vector2.LEFT.rotated(player.rotation)*50 - player.attracted.position).length_squared():
			player.attracted = self
	if not (in_attraction_area and Input.is_action_pressed("ui_select")):
		speed = linear_velocity.length()
	update()

func _draw():
	for c in connected_to.keys():
		if not has_node(c):
			get_node(connected_to[c]).queue_free()
			connected_to.erase(c)
			continue
		draw_line(Vector2.ZERO, get_node(c).position - position, Color.blue, 5)

func _integrate_forces(state):
	if in_attraction_area:
		if Input.is_action_pressed("ui_select"):
			if player.attracted == self:
				state.linear_velocity = (player.position + Vector2.LEFT.rotated(player.rotation)*50 - position)*10
				attached = true
		elif attached:
			state.linear_velocity = (position-player.position).normalized()*speed*1.25
			attached = false
	for c in state.get_contact_count():
		var h = state.get_contact_collider_object(c)
		if h is RigidBody2D and not h.get_path() in connected_to.keys() and not h in got_connected_to:
			var joint = DampedSpringJoint2D.new()
			joint.disable_collision = false
			joint.length = 15
			joint.node_a = get_path()
			joint.node_b = h.get_path()
			add_child(joint)
			connected_to[h.get_path()] = joint.get_path()
			h.got_connected_to.append(self)
