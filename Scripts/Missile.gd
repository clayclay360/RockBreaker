extends Area2D

export (int) var speed = 200 
var area = Area2D
var dir = Vector2()
var area_position = Vector2()
var velocity = Vector2()
var acceleration = Vector2()

func start(pos, dir, target):
	position = pos # position equals pos
	rotation = dir # rotation equals dir 
	area = target # area equals target
	velocity = Vector2(speed,0).rotated(dir) # velocity equals speed along the x axis, rotated by the direction
	get_corrdinate() # run get_coordinate 

func _physics_process(delta):
	position += velocity * delta # increase the position by the velocity multiplied by delta
	#rotation = velocity.angle() * delta
	if area != null:
		lock_on() # run lock_on
	
func get_corrdinate():
	if area != null:
		area_position = area.position # equal the area's position
		
func lock_on():
	dir = area.position - position # have dir equal the area's position subtracted by it's (itself, the missile) position
	dir.normalized() # normalize the vector2
	acceleration += (dir-velocity).normalized() # increase the acceleration by dir minus velocity and get that vector's normalization
	velocity += acceleration # velocity plus equals acceleration
	rotation = velocity.angle() # rotation equals the velocity's angle
	#rotation = -dir.cross(transform.x) * 100 
	
func _on_Timer_timeout():
	queue_free() # destroy missile

func _on_Missile_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode() # run the explode function
		queue_free() # destroy missile
	
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free() # destroy missile


func _on_Missile_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(3) # run take_damage with the agrument of 3
		queue_free() # destroy missile
