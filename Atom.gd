extends RigidBody2D

onready var player = get_node('../Player')
var in_attraction_area = false
var attached = false
var speed = 0
var connected_to = {}
var got_connected_to = []
var type_atom = 0
const atom_sprites = [
	preload("res://assets/1.png"),
	preload("res://assets/2.png"),
	preload("res://assets/3.png"),
	preload("res://assets/4.png"),
	preload("res://assets/5.png"),
	preload("res://assets/6.png"),
	preload("res://assets/7.png"),
	preload("res://assets/8.png"),
	preload("res://assets/9.png"),
	preload("res://assets/10.png"),
	preload("res://assets/11.png"),
	preload("res://assets/12.png"),
	preload("res://assets/13.png"),
	preload("res://assets/14.png"),
	preload("res://assets/15.png"),
	preload("res://assets/16.png"),
	preload("res://assets/17.png"),
	preload("res://assets/18.png"),
	preload("res://assets/19.png"),
	preload("res://assets/20.png"),
	preload("res://assets/21.png"),
	preload("res://assets/22.png")
]
   
func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()
	type_atom = random.randi_range(0, 21)
	$Sprite.set_texture(atom_sprites[type_atom])
	
	 

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
