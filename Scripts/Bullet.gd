extends Area2D

export (int) var speed
var velocity = Vector2()

func start(pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed,0).rotated(dir)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()


func _on_Bullet_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()


func _on_Bullet_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(1)
		queue_free()
