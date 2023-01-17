extends RigidBody2D

onready var player = get_node('../Player')
var in_attraction_area = false
var speed = 0
var scal = 1

const electric_strengh = 10000

var atom_type = 0

var connections = {}

var outer_electrons = 0
var elneg = 0
#const connections_strengh = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
const electronegativity = [2.2, 0, 0.98, 1.57, 2.04, 2.55, 3.04, 3.44, 3.98, 0, 0.93, 1.31, 1.61, 1.9, 2.19, 2.58, 3.16, 0.82, 1, 2.36, 0, 0]

func connect_atom(h):
	var joint = DampedSpringJoint2D.new()
	joint.disable_collision = false
	joint.length = 15
	joint.node_a = get_path()
	joint.node_b = h.get_path()
	get_parent().add_child(joint)
	connections[h.get_path()] = joint
	h.connections[get_path()] = joint

func _ready():
	elneg = electronegativity[atom_type]
	outer_electrons = (atom_type-1) % 8
	if atom_type in [0, 1]: # Hydrogen/Helium
		scal = 0.8
		outer_electrons = 1
	elif atom_type == 21: # Uranium
		scal = 1.4
	elif atom_type > 18: # Tungsten/Thorium
		scal = 1.2
		outer_electrons = 2
	elif atom_type > 9:
		scal = 1.1
		if atom_type > 16: outer_electrons+=1
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
				state.linear_velocity = (player.position + Vector2.LEFT.rotated(player.rotation)*50 - position)*20
	
	if not atom_type in [1, 9, 20, 21]:
		for c in state.get_contact_count():
			var h = state.get_contact_collider_object(c)
			if h is RigidBody2D:
				if abs(h.elneg - elneg) > 1.7:
					var anion = h
					var cation = self
					if h.elneg < elneg:
						anion = self
						cation = h
					
					if cation.outer_electrons == 0 or anion.outer_electrons == 8:
						continue # TODO: look at current bonds and if this one is stonger remove them
					
					var electons_transfered = min(cation.outer_electrons, 8-anion.outer_electrons)
					cation.outer_electrons -= electons_transfered
					anion.outer_electrons += electons_transfered
					connect_atom(h)
				else:
					var a = 2 if atom_type == 0 else 8
					var b = 2 if h.atom_type == 0 else 8
					var electrons_shared = 1
					# aussi todo: la suppression des molecules
					
					if outer_electrons+electrons_shared>a and h.outer_electrons+electrons_shared>b:
						continue #TODO: look at current bonds and if this one is stonger remove them
					
					outer_electrons += electrons_shared
					h.outer_electrons += electrons_shared
					connect_atom(h)
