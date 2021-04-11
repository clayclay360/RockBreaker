extends Area2D

export (int) var speed
var velocity = Vector2()

# start function: called when the enemy bullet enters the scene
func start(pos, dir):
	position = pos 
	rotation = dir
	velocity = Vector2(speed,0).rotated(dir)

# called every frame
func _process(delta):
	position += velocity * delta # increase the position of the bullet by the velocity multiplied by delta

# this function is called when the node is outside of the screen's view
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free() # destroy bullet

func _on_EnemyBullet_body_entered(body):
	if body.name == "Player":
		body.take_damage(1) # run the take damage function with the argument of 1
		queue_free() # destroy bullet 
	if body.is_in_group("rocks"):
		body.explode() # run the explode function
		queue_free() # destroy bullet

# this function is called when the bullet enters another node's area
func _on_EnemyBullet_area_entered(area):
	if area.is_in_group("forcefield"):
		queue_free() # destory bullet
