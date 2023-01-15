extends RigidBody2D

onready var player = get_node('../Player')
var in_attraction_area = false
var attached = false
var speed = 0
var scal = 1

var atom_type = 0

var connections = {}

#var outer_electrons = 0
var elneg = 0
#const connections_strengh = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
const electronegativity = [2.2, 0, 0.98, 1.57, 2.04, 2.55, 3.44, 3.98, 0, 0.93, 1.31, 1.61, 1.9, 2.19, 2.58, 3.16, 0.82, 1, 2.36, 0, 0]

func _ready():
	elneg = electronegativity[atom_type]
	if atom_type == 0: # Hydrogen
		scal = 0.7
	elif atom_type == 21: # Uranium
		scal = 1.4
	elif atom_type > 18: # Tungsten/Thorium
		scal = 1.2
	elif atom_type > 9:
		scal = 1.1
	$CollisionShape2D.scale.x = scal
	$CollisionShape2D.scale.y = scal
	scal *= 25
	
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
	for c in connections.keys():
		if not has_node(c):
			connections[c].queue_free()
			connections.erase(c)
			continue
		var a = get_node(c)
		var b = a.position - position
		var d = a.get_node('./CollisionShape2D').scale.x
		draw_line(b.normalized()*scal, b-(b.normalized()*a.scal), Color.white, 5)

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
		if h is RigidBody2D and not h.get_path() in connections.keys():
			var joint = DampedSpringJoint2D.new()
			joint.disable_collision = false
			joint.length = 15
			joint.node_a = get_path()
			joint.node_b = h.get_path()
			get_parent().add_child(joint)
			connections[h.get_path()] = joint
			h.connections[get_path()] = joint
