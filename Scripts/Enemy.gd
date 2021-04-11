extends Area2D

signal shoot
signal dead

export (PackedScene) var Bullet
export (int) var speed = 150
export (int) var health = 3

var follow
var target = null

# call this function when the node enters the scene
func _ready():
	$Sprite.frame = randi()%3 # have the nodes sprite frame equal a random number between 0 and 2
	var path = $EnemyPaths.get_children()[randi()%$EnemyPaths.get_child_count()] # create a local variable called path and have it equal to one of the nodes paths
	follow = PathFollow2D.new() # create a local variable called follow and have it equal to the new PathFollow2d
	path.add_child(follow) # add follow as a children to path
	follow.loop = false # looping equals false
	
# call this function every frame
func _process(delta):
	follow.offset += speed * delta # have the node follow offset increase by the speed multiplied by delta
	position = follow.position # have the node's position equal the follow position
	if(follow.unit_offset > 1):
		queue_free() # destroy enemy
		
# call this function when the animation in the AnimationPlayer finishes
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free() # destroy enemy 

# call this fucntion when the Timer times out
func _on_Timer_timeout():
	shoot_pulse(3, .15) # call function shoot_pulse with two arguments
	
# shoot function: get the direction of where the bullet is supposed to go, have the bullet randomly rotate in between a the range. emit the signal shoot.
func shoot():
	var dir = target.global_position - global_position # local  variable dir equals the target global position subtracted by it's (self) global position
	dir = dir.rotated(rand_range(-0.1,0.1)).angle() # dir equals itself rotated in between a range (bullets shoot out randomly)
	emit_signal("shoot", Bullet, global_position, dir) # emit signal shoot along with the following agruments
	
# shoot_pulse function: shoot a bullet series of bullets, in between each bullet thier will be a small delay. everytime a bullet is shoot play the bullet audio.	
func shoot_pulse(rounds, delay):
	for i in range(rounds):
		shoot() #call the shoot function
		$BulletAudio.play() # play the bullet audio
		yield(get_tree().create_timer(delay), "timeout") # wait for a certain amount of seconds

func take_damage(amount):
	health -= amount # subtract health by amount
	$AnimationPlayer.play("flash") # play the animation flash
	if health <= 0:
		explode() # call explode function
		emit_signal("dead") # emit signal dead
	yield($AnimationPlayer, "animation_finished") # wait for the animation to finish to proceed
	$AnimationPlayer.play("rotate") # play the rotate animation

func explode():
	speed = 0 # set speed to zero
	$Timer.stop() # stop the timer
	$CollisionShape2D.disabled = true # disable collision shape 2d
	$Sprite.hide() # hide the spirte
	$Explosion.show() # show the explosion child node
	$Explosion/AnimationPlayer.play("Explosion") # play the explosion animation


func _on_Enemy_body_entered(body):
	if body.name == "Player":
		pass
	explode() #run the explode function
