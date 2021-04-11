extends Node2D

export (PackedScene) var Rock
export (PackedScene) var Enemy
var screen_size
var game_time = 0
var kills = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # this function will randomize all the numbers when randi is called or being used 
	$Player.position = $StartPosition.position # have player's position equal start position
	$Player.change_state($Player.INIT) # change the players state to INIT
	$EnemyTimer.wait_time = rand_range(5,10) # have the enemy timer wait between a certain range
	$EnemyTimer.start() # start enemy timer
	screen_size = get_viewport().get_visible_rect().size # get the screen size
	$Player.screen_size = screen_size # put the screen size in the player's screen size variable
	for x in range(3):
		spawn_rock(3) # run the spawn rock function with the argument of 3
	$GameplayAudio.play(GameState.audio_time + 1) # play the game play audio and start the audio at the given time


func spawn_rock(size, pos = null, vel = null):
	if !pos:
		$RockPath/RockSpawn.set_offset(randi()) # set the rock spawn off set to a random number
		pos = $RockPath/RockSpawn.position # get the rock spawn position
	if !vel:
		vel = Vector2(1,0).rotated(rand_range(9,2 * PI)) * rand_range(100,150) # move the velocity right along the x axis and rotation between a random range
	var r = Rock.instance() # create a rock instance variable
	r.screen_size = screen_size # put the screen size in the rock instance screen size
	r.start(pos, vel, size) # called the rock instance start function and pass along the specific arguments
	$Rocks.add_child(r) # add the rock instance as a child to the rock node	
	r.connect("exploded", self, "_on_Rock_exploded") # connect the signal explode from the rock to the main script

# this function is called every frame
func _process(delta):
	ammo_ui() # run the ammo ui function
	get_players_high() run the get players high function
	var mouse_pos = get_global_mouse_position() # get the global mouse position and store it inside the local variable mouse_pos
	$Ray.set_cast_to(mouse_pos) # run the set_cast_to function of the 2D ray with the agrument of the mouse_pos

func _on_Player_shoot(bullet, pos, dir):
	var b = bullet.instance() # create bullet instance
	b.start(pos,dir) # call the start function of the bullet instance with the following agruments 
	add_child(b) # add the bullet instance into the scene 
	
func _on_Enemy_shoot(bullet, pos, dir):
	var b = bullet.instance() # create bullet instance
	b.start(pos,dir) # call the start function of the bullet instance with the following agruments
	add_child(b) # add the bullet instance into the scene

func _on_Rock_exploded(size, radius, pos, vel):
	if size <= 1:
		return
	for offset in [-1,1]:
		var dir = (pos - $Player.position).normalized().tangent() * offset # get the opposite direction of the where the collision of the rock was hit
		var newpos = pos + dir * radius # get the new position by adding the position and direction of the rock multiplied by it's radius
		var newvel = dir * vel.length() * 1.1 # the new velocity equals the direction multiplied by the veloicties length
		spawn_rock(size - 1, newpos, newvel) # run the spawn rock function with the new variables as agruments

func _on_EnemyTimer_timeout():
	var e = Enemy.instance() # create enemy instance
	add_child(e) # add enemy instance into the scene
	e.target = $Player # enemy target equals player
	e.connect("shoot",self,"_on_Enemy_shoot") # connect signal shoot from enemy to main script
	e.connect("dead", self,"_add_kill_score") # connect signal dead from enemy to main script

func _on_Player_dead():
	yield(get_tree().create_timer(1), "timeout") # wait for 1 sec
	get_tree().change_scene("res://Scenes/TitleScreen.tscn") # load title screen
	GameState.audio_time = $GameplayAudio.get_playback_position() # get the gameplay audio position and store it into the audio time variable

func _on_RockSpawnTimer_timeout():
	spawn_rock(2) # spawn rock with the argument of 2

func _on_Player_hit():
	$HealthBar.value = $Player.lives # set the health bar value to the number of lives the player has 

func ammo_ui():
	$AmmoBar.value = $Player.ammo_count # set the ammo bar value to the number of ammo the player has

func get_players_high():
	if game_time > GameState.high_score:
		GameState.high_score = game_time # set the high score to the game time number 

func _on_GameTimer_timeout():
	game_time += 1 # add one to the game time
	$TimeDisplayLabel.text = String(game_time) + "s" # display the game time in the display label text

func _add_kill_score():
	print("killed") # print killed
	kills += 1 # add one to kills
	$KillsLabel.text = String(kills) # display the number of kills in the kill label text

func _on_Player_shoot_missile(missile, pos, dir, target):
	var m = missile.instance() # create a missile instance 
	add_child(m) # add missile to the scene
	if $Ray.is_colliding():
		target = $Ray.get_collider() # set the target to equal the collider that intersects the ray
	m.start(pos,dir,target) # run the missile's start function with the three arguments
