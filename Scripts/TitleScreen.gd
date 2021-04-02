extends Control


var audio_time

# Called when the node enters the scene tree for the first time.
func _ready():
	$GameplayAudio.play(GameState.audio_time)
	$HighScoreLabel.text = "high score: " + String(GameState.high_score) + "s"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_pressed():
	GameState.audio_time = $GameplayAudio.get_playback_position()
	get_tree().change_scene("res://Scenes/Main.tscn")
	
