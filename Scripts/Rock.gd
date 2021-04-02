extends RigidBody2D

var screen_size = Vector2()
var size = Vector2()
var radius
var scale_factor = 0.2

signal exploded

func start(pos, velocity, _size):
	position = pos
	size = _size
	mass = 1.5 * size
	$Sprite.scale = Vector2(1,1) * scale_factor * size
	radius = int($Sprite.texture.get_size().x / 2 * scale_factor * size)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	linear_velocity = velocity
	angular_velocity = rand_range(-1.5,1.5)
	$Explosion.scale = Vector2(.75,.75) * size

func explode():
	layers = 0
	$Sprite.hide()
	$Explosion/AnimationPlayer.play("Explosion")
	emit_signal("exploded", size, radius, position, linear_velocity)
	linear_velocity = Vector2()
	angular_velocity = 0

func _integrate_forces(state):
	var xform = state.get_transform()
	if xform.origin.x > screen_size.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screen_size.x
	if xform.origin.y > screen_size.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screen_size.y
	state.set_transform(xform)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.queue_free()
