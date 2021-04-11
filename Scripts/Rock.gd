extends RigidBody2D

var screen_size = Vector2()
var size = Vector2()
var radius
var scale_factor = 0.2

signal exploded

func start(pos, velocity, _size):
	position = pos # set to pos
	size = _size # size equals _size 
	mass = 1.5 * size # mass equals 1.5 multiplied by size
	$Sprite.scale = Vector2(1,1) * scale_factor * size # scale the srpite by the scale factor multiplied by Vector2(1,1)
	radius = int($Sprite.texture.get_size().x / 2 * scale_factor * size) # set radius to equal the sprites texture size x divided by 2, then multiply that number by 2, the scale factor and then the size
	var shape = CircleShape2D.new() # create a new circle shape 2D
	shape.radius = radius # set the raduis of the shape to equal the raduis 
	$CollisionShape2D.shape = shape # set the shape of the collision shape 2D to equal shape 
	linear_velocity = velocity # set to equal velocity 
	angular_velocity = rand_range(-1.5,1.5) # set angular velocity to equal a random range between a specific value
	$Explosion.scale = Vector2(.75,.75) * size # scale the explosion by a vector2(0.75,0.75)

func explode():
	layers = 0 # set to zero
	$Sprite.hide() # hide the sprite
	$Explosion/AnimationPlayer.play("Explosion") # play the explosion animation
	emit_signal("exploded", size, radius, position, linear_velocity) # emit the signal exploded
	linear_velocity = Vector2() # set the linear velocity to equal a empty vector 2
	angular_velocity = 0 #set to zero

func _integrate_forces(state):
	var xform = state.get_transform() # create a new local variable called xform and set it equal to the transform of the state the node is in
	if xform.origin.x > screen_size.x:
		xform.origin.x = 0 # set to zero
	if xform.origin.x < 0:
		xform.origin.x = screen_size.x # set x to equal screen size x
	if xform.origin.y > screen_size.y:
		xform.origin.y = 0 # set to zero
	if xform.origin.y < 0:
		xform.origin.y = screen_size.y # set y to screen size y
	state.set_transform(xform) # set the state transform to xform 

this function is called when the node enters the scene
func _ready():
	pass # Replace with function body.


this function is called every frame
#func _process(delta):
#	pass

#this function is called when a animation is finished playing
func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.queue_free() # destroy explosion node 
