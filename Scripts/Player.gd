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
	screen_size = get_viewport().get_viewport().size # get the viewport size 
	$GunTimer.wait_time = fire_rate # wait time equals fire rate
	current_engine_power = engine_power # set current engine power to engine power
	max_ammo_count = ammo_count # set max ammo count to ammo count

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.disabled = true # set the collision shape to be disabled 
			$Ship.modulate.a = 0.5 # modulate the alpha of the sprite to 0.5
			pass
		ALIVE:
			$CollisionShape2D.disabled = false # set the collision shape to be enabled
			$Ship.modulate.a = 1 # modulate the aplha of the sprite to 1
			pass
		INVULNERABLE:
			$CollisionShape2D.disabled = true # set the collision shape to be disabled
			$Ship.modulate.a = 0.5 # modulate the aplha of the sprite to 0.5
			pass
		DEAD:
			$CollisionShape2D.disabled = true # set the collision shape to be disablled
			$Ship.hide() # hide the ship node
			linear_velocity = Vector2() # set to equal vector2
			engine_power = 0 # set to zero
			emit_signal("dead") # emit signal dead
			pass
	state = new_state # equal new state

func _process(delta): 
	get_input() # run get_input function 

func get_input():
	thrust = Vector2() # equal new vector 2
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power,0) # set thrust to equal vector 2, having engine power manipulate the x axis of the vector
	rotation_dir = 0 # equal zero
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1 # plus equal 1
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1 # minus equal 1
	if Input.is_action_pressed("shoot") and can_shoot and fire_ready and state != DEAD:
		shoot() # run the shoot function
	if Input.is_action_just_pressed("thrust"):
		if taps == 0:
			taps += 1 # add one to taps
			$DoubleTapTimer.start() # start the double tap timer
		elif taps == 1 && $DoubleTapTimer.time_left > 0:
			engine_power += 500 # add 500 to engine power
			$BoostAudio.play() # play the boost audio sound
	if Input.is_action_just_pressed("missile"):
		shoot_missile() # run the shoot_missile function 
	if Input.is_action_just_pressed("shield") and state != DEAD and can_shield:
		$ForceField.visible = true # visibility equals true
		$ForceField/CollisionShape2D.disabled = false # visibility equals false
		$ForceFieldTimer.start() # start the force field timer
	if Input.is_action_just_pressed("reload") and state != DEAD and can_reload:
		fire_ready = false # set to false
		can_reload = false # set to false
		$CoolDownTimer.start() # start cool down timer

func shoot():
	if state == INVULNERABLE:
		return

	if ammo_count > 0 and fire_ready:
		emit_signal("shoot", Bullet, $Muzzle.global_position, rotation) # emit signal shoot
		can_shoot = false # set to false
		can_reload = true # set to true 
		$GunTimer.start() # start gun timer 
		$BulletAudio.play() # play bullet audio sound
		ammo_count -= 1 # subtract one from ammo_count
	else:
		$CoolDownTimer.start() # start cool down timer
		fire_ready = false # set to false

func shoot_missile():
	if state == INVULNERABLE:
		return

	if missile_ready:
		emit_signal("shoot_missile", Missile, $Muzzle.global_position, rotation, null) # emit signal shoot missile
		missile_ready = false # set to false
		$MissileTimer.start() # start missile timer

func _physics_process(delta):
	set_applied_force(thrust.rotated(rotation)) # apply force to the forward thrust of the player (depending on thier rotation)
	set_applied_torque(spin_power * rotation_dir) # apply torque to the player (depending on where they want to turn)

func _integrate_forces(state):
	set_applied_force(thrust.rotated(rotation)) # apply force to the forward thrust of the player (depending on thier rotation)
	set_applied_torque(spin_power * rotation_dir) # apply torque to the player (depending on where they want to turn)
	var xform = state.get_transform() # get the players transform (depending on their rigibody)
	if xform.origin.x > screen_size.x: 
		xform.origin.x = 0 # set to zero
		stop_trail() # run the stop_trail function
	if xform.origin.x < 0:
		xform.origin.x = screen_size.x # set x to the screen_size x
		stop_trail() # run the stop_trail function
	if xform.origin.y > screen_size.y:
		xform.origin.y = 0 # set to zero
		stop_trail() # run the stop_tail function
	if xform.origin.y < 0:
		xform.origin.y = screen_size.y # set y to screen_size y
		stop_trail() # run the stop_trail function
	state.set_transform(xform) # set the transform to equal xform

func _on_GunTimer_timeout():
	can_shoot = true # set to true

func _on_InvulnerabilityTimer_timeout():
	change_state(ALIVE) # change the state to ALIVE

func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.hide() # hide the explosion node once the explosion animation is finished

func take_damage(amount):
		$Explosion.show() # show the explosion node child
		$Explosion/AnimationPlayer.play("Explosion") # play the explosion animation
		$InvulnerabilityTimer.start() # start the invulnerability timer 
		$ForceField.visible = false # set the visibility to false 
		$ForceField/CollisionShape2D.disabled = true # disable the collision shape
		lives -= amount # subtract the amount from lives
		emit_signal("hit") # emit signal hit
		if lives <= 0:
			change_state(DEAD) # change state to DEAD
		else:
			change_state(INVULNERABLE) # change state to INVULNERABLE

func _on_Player_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode() # run the explode function
		take_damage(1) # run the take_damage function with the agrument of 1

func _on_StartTimer_timeout():
	change_state(ALIVE) # change state to ALIVE

func _on_CoolDownTimer_timeout():
	for i in range(max_ammo_count-ammo_count):
		if ammo_count != max_ammo_count:
			yield(get_tree().create_timer(.05), "timeout") # wait for .05 seconds
			ammo_count += 1 # add one to ammo_count
	fire_ready = true # set to true

func stop_trail():
	$RTrails/RightTrail.visible = false # set to false
	$LTrails/LeftTrail.visible = false # set to false
	$TrailTimer.start() # start trail timer

func _on_DoubleTapTimer_timeout():
	taps = 0 # set to zero 
	engine_power = current_engine_power # set engine power to current engine power 


func _on_TrailTimer_timeout():
	$RTrails/RightTrail.visible = true # set to true
	$LTrails/LeftTrail.visible = true # set to true


func _on_ForceFieldTimer_timeout():
	$ForceField.visible = false # set to false
	$ForceField/CollisionShape2D.disabled = true # disable the collision shape
	can_shield = false # set to false
	yield(get_tree().create_timer(5), "timeout") # wait 5 seconds 
	can_shield = true # set to true

func _on_MissileTimer_timeout():
	missile_ready = true # set to true
