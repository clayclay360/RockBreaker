extends Node2D

export (PackedScene) var Rock
export (PackedScene) var Enemy
var screen_size
var game_time = 0
var kills = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Player.position = $StartPosition.position
	$Player.change_state($Player.INIT)
	$EnemyTimer.wait_time = rand_range(5,10)
	$EnemyTimer.start()
	screen_size = get_viewport().get_visible_rect().size
	$Player.screen_size = screen_size
	for x in range(3):
		spawn_rock(3)
	$GameplayAudio.play(GameState.audio_time + 1)


func spawn_rock(size, pos = null, vel = null):
	if !pos:
		$RockPath/RockSpawn.set_offset(randi())
		pos = $RockPath/RockSpawn.position
	if !vel:
		vel = Vector2(1,0).rotated(rand_range(9,2 * PI)) * rand_range(100,150)
	var r = Rock.instance()
	r.screen_size = screen_size
	r.start(pos, vel, size)
	$Rocks.add_child(r)	
	r.connect("exploded", self, "_on_Rock_exploded")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ammo_ui()
	get_players_high()
	var mouse_pos = get_global_mouse_position()
	$Ray.set_cast_to(mouse_pos)

func _on_Player_shoot(bullet, pos, dir):
	var b = bullet.instance()
	b.start(pos,dir)
	add_child(b)
	
func _on_Enemy_shoot(bullet, pos, dir):
	var b = bullet.instance()
	b.start(pos,dir)
	add_child(b)

func _on_Rock_exploded(size, radius, pos, vel):
	if size <= 1:
		return
	for offset in [-1,1]:
		var dir = (pos - $Player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel)

func _on_EnemyTimer_timeout():
	var e = Enemy.instance()
	add_child(e)
	e.target = $Player
	e.connect("shoot",self,"_on_Enemy_shoot")
	e.connect("dead", self,"_add_kill_score")

func _on_Player_dead():
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
	GameState.audio_time = $GameplayAudio.get_playback_position()

func _on_RockSpawnTimer_timeout():
	spawn_rock(2)

func _on_Player_hit():
	$HealthBar.value = $Player.lives

func ammo_ui():
	$AmmoBar.value = $Player.ammo_count

func get_players_high():
	if game_time > GameState.high_score:
		GameState.high_score = game_time

func _on_GameTimer_timeout():
	game_time += 1
	$TimeDisplayLabel.text = String(game_time) + "s"

func _add_kill_score():
	print("killed")
	kills += 1
	$KillsLabel.text = String(kills)

func _on_Player_shoot_missile(missile, pos, dir, target):
	var m = missile.instance()
	add_child(m)
	if $Ray.is_colliding():
		target = $Ray.get_collider()
	m.start(pos,dir,target)
