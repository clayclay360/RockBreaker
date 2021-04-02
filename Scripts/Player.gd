extends RigidBody2D


enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = null
export (int) var engine_power
export (int) var spin_power
export (int) var ammo_count
export (float) var fire_rate
export (PackedScene) var Bullet
export (PackedScene) var Missile

var thrust = Vector2()
var rotation_dir = 0
var can_shoot = true
var can_shield = true
var can_reload = false
var missile_ready = true
var max_ammo_count
var lives = 3
var fire_ready = true
var taps = 0
var current_engine_power

var screen_size = Vector2()
var target = Area2D

signal shoot
signal shoot_missile
signal dead
signal hit
signal screen_change

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().get_viewport().size
	$GunTimer.wait_time = fire_rate
	current_engine_power = engine_power
	max_ammo_count = ammo_count

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.disabled = true
			$Ship.modulate.a = 0.5
			pass
		ALIVE:
			$CollisionShape2D.disabled = false
			$Ship.modulate.a = 1
			pass
		INVULNERABLE:
			$CollisionShape2D.disabled = true
			$Ship.modulate.a = 0.5
			pass
		DEAD:
			$CollisionShape2D.disabled = true
			$Ship.hide()
			linear_velocity = Vector2()
			engine_power = 0
			emit_signal("dead")
			pass
	state = new_state

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
	if Input.is_action_pressed("shoot") and can_shoot and fire_ready and state != DEAD:
		shoot()
	if Input.is_action_just_pressed("thrust"):
		if taps == 0:
			taps += 1
			$DoubleTapTimer.start()
		elif taps == 1 && $DoubleTapTimer.time_left > 0:
			engine_power += 500
			$BoostAudio.play()
	if Input.is_action_just_pressed("missile"):
		shoot_missile()
	if Input.is_action_just_pressed("shield") and state != DEAD and can_shield:
		$ForceField.visible = true
		$ForceField/CollisionShape2D.disabled = false
		$ForceFieldTimer.start()
	if Input.is_action_just_pressed("reload") and state != DEAD and can_reload:
		fire_ready = false
		can_reload = false
		$CoolDownTimer.start()

func shoot():
	if state == INVULNERABLE:
		return

	if ammo_count > 0 and fire_ready:
		emit_signal("shoot", Bullet, $Muzzle.global_position, rotation)
		can_shoot = false
		can_reload = true
		$GunTimer.start()
		$BulletAudio.play()
		ammo_count -= 1
	else:
		$CoolDownTimer.start()
		fire_ready = false

func shoot_missile():
	if state == INVULNERABLE:
		return

	if missile_ready:
		emit_signal("shoot_missile", Missile, $Muzzle.global_position, rotation, null)
		missile_ready = false
		$MissileTimer.start()

func _physics_process(delta):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)

func _integrate_forces(state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
	var xform = state.get_transform()
	if xform.origin.x > screen_size.x:
		xform.origin.x = 0
		stop_trail()
	if xform.origin.x < 0:
		xform.origin.x = screen_size.x
		stop_trail()
	if xform.origin.y > screen_size.y:
		xform.origin.y = 0
		stop_trail()
	if xform.origin.y < 0:
		xform.origin.y = screen_size.y
		stop_trail()
	state.set_transform(xform)

func _on_GunTimer_timeout():
	can_shoot = true

func _on_InvulnerabilityTimer_timeout():
	change_state(ALIVE)

func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.hide()

func take_damage(amount):
		$Explosion.show()
		$Explosion/AnimationPlayer.play("Explosion")
		$InvulnerabilityTimer.start()
		$ForceField.visible = false
		$ForceField/CollisionShape2D.disabled = true
		lives -= amount
		emit_signal("hit")
		if lives <= 0:
			change_state(DEAD)
		else:
			change_state(INVULNERABLE)

func _on_Player_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
		take_damage(1)

func _on_StartTimer_timeout():
	change_state(ALIVE)

func _on_CoolDownTimer_timeout():
	for i in range(max_ammo_count-ammo_count):
		if ammo_count != max_ammo_count:
			yield(get_tree().create_timer(.05), "timeout")
			ammo_count += 1
	fire_ready = true

func stop_trail():
	$RTrails/RightTrail.visible = false
	$LTrails/LeftTrail.visible = false
	$TrailTimer.start()

func _on_DoubleTapTimer_timeout():
	taps = 0
	engine_power = current_engine_power


func _on_TrailTimer_timeout():
	$RTrails/RightTrail.visible = true
	$LTrails/LeftTrail.visible = true


func _on_ForceFieldTimer_timeout():
	$ForceField.visible = false
	$ForceField/CollisionShape2D.disabled = true
	can_shield = false
	yield(get_tree().create_timer(5), "timeout")
	can_shield = true

func _on_MissileTimer_timeout():
	missile_ready = true
