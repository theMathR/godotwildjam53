extends RigidBody2D

onready var player = get_node('../../Player')
onready var connections_parent = get_node('../../Connections')
var in_attraction_area = false

var scal = 1

var atom_type = 0

var on_screen = true

var connections = {}

const atom_names = ['H', 'He', 'Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne', 'Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'K', 'Ca', 'W', 'Th', 'U', 'Ohio']

func connect_atom(h):
	var joint = DampedSpringJoint2D.new()
	joint.disable_collision = false
	joint.length = 15
	joint.node_a = get_path()
	joint.node_b = h.get_path()
	connections_parent.add_child(joint)
	connections[h] = joint
	h.connections[self] = joint

func _ready():
	if atom_type in [0, 1]: # Hydrogen/Helium
		scal = 0.8
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
	on_screen = false

func _on_VisibilityNotifier2D_screen_entered():
	on_screen = true

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
	update()
	try_remove()

func try_remove(a=[]):
	if on_screen: return false
	a.append(self)
	var h = true
	for c in connections.keys():
		if not c in a:
			h = h and c.try_remove(a)
	if h:
		do_remove()

func do_remove(a=[]):
	a.append(self)
	for c in connections.keys():
		if not c in a:
			c.do_remove(a)
		if connections[c]:
			connections[c].queue_free()
	queue_free()

func get_molecule(a=[]):
	var b=a.duplicate()
	b.append(self)
	for c in connections.keys():
		if not c in b:
			b=c.get_molecule(b)
	if a: return b
	
	var atom_types = {}
	for h in b:
		if h.atom_type in atom_types.keys():
			atom_types[h.atom_type] += 1
		else:
			atom_types[h.atom_type] = 1
	
	var formula = ''
	if 5 in atom_types.keys():
		formula += 'C' + (str(atom_types[5]) if atom_types[5] > 1 else '')
		atom_types.erase(5)
	if 0 in atom_types.keys():
		formula += 'H' + (str(atom_types[0]) if atom_types[0] > 1 else '')
		atom_types.erase(0)
	for i in range(23):
		if i in atom_types.keys():
			formula += atom_names[i] + (str(atom_types[i]) if atom_types[i] > 1 else '')
	print(formula)
	return formula

func _draw():
	for c in connections.keys():
		var b = c.position - position
		var d = c.get_node('./CollisionShape2D').scale.x
		draw_line(b.normalized()*scal, b-(b.normalized()*c.scal), Color.white, 5)

func _integrate_forces(state):
	if in_attraction_area:
		if Input.is_action_pressed("ui_select"):
			if player.attracted == self:
				state.linear_velocity = (player.position + Vector2.LEFT.rotated(player.rotation)*50 - position)*20

	for c in state.get_contact_count():
		var h = state.get_contact_collider_object(c)
		if h == player:
			var speed = linear_velocity.length()
			if speed > 500:
				h.damage(floor(linear_velocity.length()/25))
			if atom_type == 22:
				h.damage(25)
		elif h is RigidBody2D:
			connect_atom(h)
