extends RigidBody2D

onready var player = get_node('../../Player')
onready var connections_parent = get_node('../../Connections')
var in_attraction_area = false

var scal = 1

var atom_type = 0

var on_screen = true

var no_damage = false

var connections = {}

const atom_names = ['H', 'He', 'Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne', 'Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'K', 'Ca', 'W', 'Th', 'U', 'Ohio']

var electrons = 0

var connection_to_remove = []

var damage_speed = 500

export (PackedScene) var uranium_proj

const connection_rules = [
	{0:0, 5:100, 16:0, 7:100, 6:75, 15:50},						# 0 Hydrogen
	{},											# (1 Helium)
	{7:200},											# 2 Lithium
	{},											# 3 Berylium
	{8:100},											# 4 Borus
	{5:101, 0:100, 7: 105, 6:102, 17:103, 19:100},								# 5 Carbon
	{0:75, 5:100, 6:1},											# 6 Nitrogen
	{10:0, 0:100, 5:105, 19:105, 7:100, 15:25, 2:200, 13:1000},								# 7 Oxygen
	{4:100, 10:50},											# 8 Fluorine
	{},											# (9 Neon)
	{16:100, 7:0, 8:50},								# 10 Sodium
	{},											# 11 Magnesium
	{},											# 12 Aluminium
	{7:1000},											# 13 Silicium
	{14:100},											# 14 Phosphorus
	{7:25, 0:50},											# 15 Sulfur
	{0:0, 10:100, 18:150},							# 16 Chloride
	{5:103},											# 17 Potassium
	{16:150},										# 18 Calcium
	{5:100, 7:105},											# 19 Tungsten
	{},											# (20 Thorium)
	{},											# (21 Uranium)
	{},											# (22 Ohium)
]

func connect_atom(h):
	var joint = DampedSpringJoint2D.new()
	joint.disable_collision = false
	joint.length = 0
	joint.node_a = get_path()
	joint.node_b = h.get_path()
	connections_parent.add_child(joint)
	connections[h] = joint
	h.connections[self] = joint

func test_connection(a):
	connection_to_remove = null
	if electrons > 0: return true
	var min_connection = a
	var m = connection_rules[atom_type][a]
	print(min_connection, ' ', m)
	for c in connections.keys():
		if m > connection_rules[atom_type][c.atom_type]:
			min_connection = c
			m = connection_rules[atom_type][c.atom_type]
	if min_connection is int: return false
	connection_to_remove = min_connection
	return true

func recursive(v, a=[]):
	no_damage = v
	a.append(self)
	for c in connections.keys():
		if not c in a: c.recursive(v, a)

func _ready():
	electrons = (atom_type-1) % 8
	if atom_type in [0, 1]: # Hydrogen/Helium
		scal = 0.8
		electrons = 1
	elif atom_type == 21: # Uranium
		scal = 1.4
	elif atom_type > 18: # Tungsten/Thorium
		scal = 1.2
		electrons = 2
	elif atom_type > 9:
		scal = 1.1
		if atom_type > 16: electrons += 1
	$CollisionShape2D.scale.x = scal
	$CollisionShape2D.scale.y = scal
	if electrons > 4: electrons = 4 - (electrons % 4)
	scal *= 25
	
func _on_VisibilityNotifier2D_screen_exited():
	on_screen = false

func _on_VisibilityNotifier2D_screen_entered():
	on_screen = true

func _on_Area2D_body_entered(body):
	if body == self and atom_type < 22: in_attraction_area = true

func _on_Area2D_body_exited(body):
	if body == self: in_attraction_area = false
	if player.attracted == self: player.attracted = null

var uranium = 0
func _physics_process(delta):
	if in_attraction_area:
		if player.attracted == null: player.attracted = self
		elif (player.position + Vector2.LEFT.rotated(player.rotation)*50 - position).length_squared() < (player.position + Vector2.LEFT.rotated(player.rotation)*50 - player.attracted.position).length_squared():
			player.attracted = self
			player.attracted.recursive(false)
		if player.attracted == self:
			recursive(true)
	var speed = linear_velocity.length()
	uranium += delta
	if speed > damage_speed and not (no_damage and Input.is_action_pressed("ui_select")):
		modulate = Color(1,0.5,0.5)
	else:
		modulate = Color.white
	if atom_type == 21: # Uranium
		$CollisionShape2D.scale.x = 1.4 + cos(uranium*8) / 8
		$CollisionShape2D.scale.y = 2.8 - $CollisionShape2D.scale.x
		if not randi() % 100:
			for i in range(8):
				var proj = uranium_proj.instance()
				proj.position = position
				proj.rotation = i * PI / 4
				get_parent().get_parent().add_child(proj)
			queue_free()
	update()
	try_remove()

func try_remove(a=[]):
	if on_screen or (player is KinematicBody2D and player.attracted == self): return false
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
		draw_line(b.normalized()*scal, b-(b.normalized()*c.scal), Color(1, 1.5, 1.5), 5)

func _integrate_forces(state):
	if in_attraction_area:
		if Input.is_action_pressed("ui_select") and player.get_node('Ray').visible:
			if player.attracted == self:
				state.linear_velocity = (player.position + Vector2.LEFT.rotated(player.rotation)*50 - position)*20
	
	for c in state.get_contact_count():
		var h = state.get_contact_collider_object(c)
		if h == player and not (no_damage and Input.is_action_pressed("ui_select")):
			var speed = linear_velocity.length()
			var damage = 0
			if speed > damage_speed:
				damage += 25
			if atom_type == 22:
				damage += 25
			if damage: h.damage(damage)
	
		elif h is RigidBody2D and not h in connections.keys():
			if not h.atom_type in connection_rules[atom_type].keys(): continue
			if not (test_connection(h.atom_type) and h.test_connection(atom_type)): continue
			prout()
			h.prout()
			electrons -= 1
			h.electrons -= 1
			connect_atom(h)

func prout():
	if not connection_to_remove: return
	connection_to_remove.electrons += 1
	electrons += 1
	connections[connection_to_remove].queue_free()
	connection_to_remove.connections.erase(self)
	connections.erase(connection_to_remove)
