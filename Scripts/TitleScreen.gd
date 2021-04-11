extends Control


var audio_time

# Called when the node enters the scene tree for the first time.
func _ready():
	$GameplayAudio.play(GameState.audio_time) # player game player audio
	$HighScoreLabel.text = "high score: " + String(GameState.high_score) + "s" # display the high score


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_pressed():
	GameState.audio_time = $GameplayAudio.get_playback_position() # set the audio time equal to the game play audio's position
	get_tree().change_scene("res://Scenes/Main.tscn") # load the main scene 
	
