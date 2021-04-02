extends Area2D

signal shoot
signal dead

export (PackedScene) var Bullet
export (int) var speed = 150
export (int) var health = 3

var follow
var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.frame = randi()%3
	var path = $EnemyPaths.get_children()[randi()%$EnemyPaths.get_child_count()]
	follow = PathFollow2D.new()
	path.add_child(follow)
	follow.loop = false

func _process(delta):
	follow.offset += speed * delta
	position = follow.position
	if(follow.unit_offset > 1):
		queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func _on_Timer_timeout():
	shoot_pulse(3, .15)

func shoot():
	var dir = target.global_position - global_position
	dir = dir.rotated(rand_range(-0.1,0.1)).angle()
	emit_signal("shoot", Bullet, global_position, dir)

func shoot_pulse(rounds, delay):
	for i in range(rounds):
		shoot()
		$BulletAudio.play()
		yield(get_tree().create_timer(delay), "timeout")

func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()
		emit_signal("dead")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("rotate")

func explode():
	speed = 0
	$Timer.stop()
	$CollisionShape2D.disabled = true
	$Sprite.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("Explosion")


func _on_Enemy_body_entered(body):
	if body.name == "Player":
		pass
	explode()
