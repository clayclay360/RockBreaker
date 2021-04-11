extends Area2D

export (int) var speed
var velocity = Vector2()

# this function will be called when the bullet is instanced, get the starting position, rotation and speed of the bullet
func start(pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed,0).rotated(dir)

# during every frame increase the position by the velocity multiplied by delta
func _process(delta):
	position += velocity * delta

# if the bullet goes outside the screen view, delete the bullet
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()

# call this function if the bullet enters another nodes body
func _on_Bullet_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode() # run the explode function
		queue_free() # destory bullet

# call this function if the bullet enters another nodes area
func _on_Bullet_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(1) # run the take_damage function and pass in the argument 1
		queue_free() # destroy bullet
