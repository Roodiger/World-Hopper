extends StaticBody2D

const METEOR_EXPLOSION = preload("res://Particles/MeteorExplode.tscn")
onready var Explosion = preload("res://Particles/Explosion.tscn")
onready var ExplosionTimer = get_node("Timer")
onready var planet = get_parent()
onready var gravityCenter = planet.get_node("GravityCenter")
var beingDestroyed = false
onready var TimerLabel
export var inGame = true
export(String) var  function 

var planetSize = null

var player
var countDown = 4

signal planet_exploded(value)

func _ready():
	if get_tree().current_scene.get_name() == "World":
		TimerLabel = get_tree().get_root().get_node("World/UI/TimerLabel")
	pass
		
	
func _process(delta):
	
	var downVector = Vector2(0, 1)
	var planetCoordsX
	var planetCoordsY
	if planetSize == null:
		
		planetSize = planet.planetSize
		
		var radius = Vector2(planetSize, 0)
		var center = gravityCenter.get_global_position()
		var step = 2 * PI / 10
		var spawn_pos = center + radius.rotated(step * rand_range(0, 10))
		
		if function == "Start":
			spawn_pos = center + radius.rotated(1.6)
		
		if function == "Mute" || function == "Quit":
			spawn_pos = center + radius.rotated(-1.6)
		
		
		global_position = spawn_pos
		set_rotation(downVector.angle_to((gravityCenter.get_global_position() - get_global_position()).normalized()))
		
	if inGame == true && beingDestroyed == false:
		if Global.buttonDisabled == true || self != get_tree().get_nodes_in_group("Buttons").front():
			$Sprite.frame = 2
			$DisabledButtonCollision.disabled = false
			$Area2D.set_deferred("set_monitorable", false)
		else:
			$Sprite.frame = 0
			$DisabledButtonCollision.disabled = true
			$Area2D.set_deferred("set_monitorable", true)
	
	if countDown == 0:
		Global.buttonDisabled = false
		var meteors = get_tree().get_nodes_in_group("Meteors")
		for meteor in meteors:
			var meteorDownVector = Vector2(0,-1)
			var effect = METEOR_EXPLOSION.instance()
			effect.set_emitting(true)
			effect.process_material.spread = 180
			var main = get_tree().current_scene
			main.add_child(effect)
			effect.global_position = meteor.get_node("Position2D").global_position
			SoundManager.play_se("MeteorExplode.wav")
			meteor.queue_free()
		var explosion = Explosion.instance()
		explosion.set_emitting(true)
		var main = get_tree().current_scene
		main.add_child(explosion)
		SoundManager.play_me("PlanetExplode.wav")
		explosion.global_position = planet.global_position
		if player:
			connect("planet_exploded", player, "_on_Button_planet_exploded")
			emit_signal("planet_exploded", planet)
		planet.queue_free()


func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		if inGame == true:
			beingDestroyed = true
			player = body
			$Sprite.frame = 1
			Global.buttonDisabled = true
			ExplosionTimer.start(1)
			$Area2D.set_deferred("set_monitorable", false)
		elif function == "Start":
			Global.playerHealth = 1
			Global.buttonDisabled = false
			Global.score = 0
			Global.palettes = Global.randomizePalette()
			get_tree().call_group("Buttons","queue_free")
			get_tree().change_scene("res://World.tscn")
		elif function == "Mute":
			AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
			if get_tree().get_root().get_node("Start/StartUI").get_child(0).text == "mute":
				Global.muteText = "unmute"
			else:
				Global.muteText = "mute"
			get_tree().reload_current_scene()
		elif function == "Quit":
			get_tree().quit()

func _on_Timer_timeout():
	if countDown > 0:
		countDown = countDown - 1
		TimerLabel.set_text(str(countDown))
