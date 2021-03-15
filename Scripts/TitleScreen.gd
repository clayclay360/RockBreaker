extends Control


var audio_time


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer2D.play(GameState.audio_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_pressed():
	GameState.audio_time = $AudioStreamPlayer2D.get_playback_position()
	get_tree().change_scene("res://Scenes/Main.tscn")
	
