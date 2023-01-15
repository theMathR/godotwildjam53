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
var atom_7 = preload("res://assets/7.png")
var atom_8 = preload("res://assets/8.png")
var atom_9 = preload("res://assets/9.png")
var atom_10 = preload("res://assets/10.png")
var atom_11 = preload("res://assets/11.png")
var atom_12 = preload("res://assets/12.png")
var atom_13 = preload("res://assets/13.png")
var atom_14 = preload("res://assets/14.png")
var atom_15 = preload("res://assets/15.png")
var atom_16 = preload("res://assets/16.png")
var atom_17 = preload("res://assets/17.png")
var atom_18 = preload("res://assets/18.png")
var atom_19 = preload("res://assets/19.png")
var atom_20 = preload("res://assets/20.png")
var atom_21 = preload("res://assets/21.png")
var atom_22 = preload("res://assets/22.png")
   
func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()
	type_atom = random.randi_range(0, 22)
	print(type_atom)
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
	elif type_atom == 7:
		$Sprite.set_texture(atom_7)
	elif type_atom == 8:
		$Sprite.set_texture(atom_8)
	elif type_atom == 9:
		$Sprite.set_texture(atom_9)
	elif type_atom == 10:
		$Sprite.set_texture(atom_10)
	elif type_atom == 11:
		$Sprite.set_texture(atom_11)
	elif type_atom == 12:
		$Sprite.set_texture(atom_12)
	elif type_atom == 13:
		$Sprite.set_texture(atom_13)
	elif type_atom == 14:
		$Sprite.set_texture(atom_14)
	elif type_atom == 15:
		$Sprite.set_texture(atom_15)
	elif type_atom == 16:
		$Sprite.set_texture(atom_16) 
	elif type_atom == 17:
		$Sprite.set_texture(atom_17)
	elif type_atom == 18:
		$Sprite.set_texture(atom_18)
	elif type_atom == 19:
		$Sprite.set_texture(atom_19)
	elif type_atom == 20:
		$Sprite.set_texture(atom_20)
	elif type_atom == 21:
		$Sprite.set_texture(atom_21)  
	elif type_atom == 22:
		$Sprite.set_texture(atom_22)  
	
	 

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
