extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

	SoundManager.play_bgm("GameMusic.ogg")
	$StartUI/Mute.text = Global.muteText
		

func _on_Player_game_over():
	Global.playerHealth = 1
	get_tree().reload_current_scene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
