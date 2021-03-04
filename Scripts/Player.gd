extends RigidBody2D


enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = null
export (int) var engine_power
export (int) var spin_power
export (PackedScene) var Bullet
export (float) var fire_rate

var thrust = Vector2()
var rotation_dir = 0
var can_shoot = true
var lives = 3

var screen_size = Vector2()

signal shoot
signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().get_viewport().size
	$GunTimer.wait_time = fire_rate

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = 0.5
			pass
		ALIVE:
			$CollisionShape2D.disabled = false
			$Sprite.modulate.a = 1
			pass
		INVULNERABLE:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = 0.5
			pass
		DEAD:
			$CollisionShape2D.disabled = true
			$Sprite.hide()
			linear_velocity = Vector2()
			emit_signal("dead")
			pass

func _process(delta):
	get_input()

func get_input():
	thrust = Vector2()
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power,0)
	rotation_dir = 0
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	if state == INVULNERABLE:
		return
	emit_signal("shoot", Bullet, $Muzzle.global_position, rotation)
	can_shoot = false
	$GunTimer.start()

func _physics_process(delta):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
	
func _integrate_forces(state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
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


func _on_GunTimer_timeout():
	can_shoot = true

func _on_InvulnerabilityTimer_timeout():
	change_state(ALIVE)

func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.hide()


func _on_Player_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
		$Explosion.show()
		$Explosion/AnimationPlayer.play("Explosion")
		$InvulnerabilityTimer.start()
		lives -= 1
		if lives <= 0:
			change_state(DEAD)
		else:
			change_state(INVULNERABLE)
