extends KinematicBody2D

func _process(delta):
	var h = move_and_collide(Vector2(300, 0).rotated(rotation) * delta)
	if h:
		h.collider.damage(25)
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _draw():
	draw_circle(Vector2.ZERO, 15, Color.white)
