extends Node2D

const METEOR = preload("res://Particles/Meteor.tscn")
onready var meteorTimer = get_node("MeteorTimer")
onready var planet = preload("res://Planets/Planet.tscn")

var scoreCounter
var meteorCounter
var closestPlanet

func _ready():
	scoreCounter = 0
	meteorCounter = 1
	Global.jumping = false
	meteorTimer.start(3)
	get_node("/root/World/UI/Score").set_text("Score: " + str(Global.score))
	
func _process(delta):
	closestPlanet = Global.closestPlanet
	if get_tree().get_nodes_in_group("Planets").size() < 10:
		var newPlanet = planet.instance()
		newPlanet.global_position = Vector2(get_tree().get_nodes_in_group("Planets").back().global_position.x + 900, get_tree().get_nodes_in_group("Planets").back().global_position.y + rand_range(-800, 800))
		add_child(newPlanet)

func _on_MeteorTimer_timeout():
	
	meteorTimer.start(rand_range(0.1, 0.5))
	
	if Global.score == scoreCounter + 5:
		scoreCounter = scoreCounter + 5
		meteorCounter = meteorCounter + 1  
	
	if closestPlanet != null && get_tree().get_nodes_in_group("Meteors").size() < meteorCounter && Global.jumping == false:
		spawnMeteor()
	

func _on_Player_game_over():
	get_node("UI/GameOver").show()
	get_node("UI/GameOver/RestartButton").grab_focus()

func _on_SubmitScoreButton_pressed():
	var name = get_node("UI/GameOver/Name").text
	SilentWolf.Scores.persist_score(name, Global.score)
	SilentWolf.Scores.get_high_scores()
	get_node("UI/GameOver").hide()
	load_leaderboard_scene()

func load_leaderboard_scene():
	get_tree().change_scene("res://addons/silent_wolf/Scores/Leaderboard.tscn")

func spawnMeteor():

	var radius = Vector2(closestPlanet.planetCollision.get_shape().radius + 500, 0)
	var center = closestPlanet.gravityCenter.global_position
	
	var step = 2 * PI / 10
	
	var spawn_pos = center + radius.rotated(step * rand_range(0, 10))
	var node = METEOR.instance()
	node.set_position(spawn_pos)
	add_child(node)

func _on_RestartButton_pressed():
	Global.playerHealth = 1
	Global.buttonDisabled = false
	Global.score = 0
	get_tree().reload_current_scene()


func _on_Name_text_entered(new_text):
	var name = get_node("UI/GameOver/Name").text
	SilentWolf.Scores.persist_score(name, Global.score)
	SilentWolf.Scores.get_high_scores()
	get_node("UI/GameOver").hide()
	load_leaderboard_scene()


func _on_MenuButton_pressed():
	get_tree().change_scene("res://Start.tscn")
