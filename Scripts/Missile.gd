extends Area2D

export (int) var speed = 200 
var area = Area2D
var dir = Vector2()
var area_position = Vector2()
var velocity = Vector2()
var acceleration = Vector2()

func start(pos, dir, target):
	position = pos
	rotation = dir
	area = target
	velocity = Vector2(speed,0).rotated(dir)
	get_corrdinate()

func _physics_process(delta):
	position += velocity * delta
	#rotation = velocity.angle() * delta
	if area != null:
		lock_on()
	
func get_corrdinate():
	if area != null:
		area_position = area.position
		
func lock_on():
	dir = area.position - position
	dir.normalized()
	acceleration += (dir-velocity).normalized()
	velocity += acceleration
	rotation = velocity.angle()
	#rotation = -dir.cross(transform.x) * 100
	
func _on_Timer_timeout():
	queue_free()

func _on_Missile_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()
	
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()


func _on_Missile_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(3)
		queue_free()
