extends RigidBody2D

onready var player = get_node('../Player')
var in_attraction_area = false
var attached = false
var speed = 0
var connected_to = {}
var got_connected_to = []
var type_atom = 0
var atom_1 = preload("res://assets/1.png")
var atom_2 = preload("res://assets/2.png")
var atom_3 = preload("res://assets/3.png")
var atom_4 = preload("res://assets/4.png")
var atom_5 = preload("res://assets/5.png")
var atom_6 = preload("res://assets/6.png")
   
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	type_atom = rng.randf_range(1 , 6)
	if type_atom == 1:
		$Sprite.set_texture(atom_1)
	elif type_atom == 2:
		$Sprite.set_texture(atom_2)
	elif type_atom == 3:
		$Sprite.set_texture(atom_3)
	elif type_atom == 4:
		$Sprite.set_texture(atom_4)
	elif type_atom == 5:
		$Sprite.set_texture(atom_5)
	elif type_atom == 6:
		$Sprite.set_texture(atom_6) 
	
	 

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
