extends KinematicBody2D

const METEOR_SPEED = 300
const ACCELERATION = 50

const METEOR_EXPLOSION = preload("res://Particles/MeteorExplode.tscn")

var closestPlanet

var velocity = Vector2.ZERO

func _ready():
	set_process(true)

func _process(delta):
	if closestPlanet == null && Global.closestPlanet != null:
		closestPlanet = Global.closestPlanet
	var downVector = Vector2(0,-1)
	if(closestPlanet != null):
		set_rotation(downVector.angle_to((closestPlanet.gravityCenter.get_global_position() - get_global_position()).normalized()))
		accelerate_towards_point(closestPlanet.gravityCenter.get_global_position(), delta)
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * METEOR_SPEED, ACCELERATION * delta)

func _on_Meteor_body_entered(body):
	if body.get_name() == "Player" && Global.dashing == false:
		Global.playerHealth = Global.playerHealth - 1
	elif closestPlanet != null: 
		var downVector = Vector2(0,-1)
		var effect = METEOR_EXPLOSION.instance()
		effect.set_emitting(true)
		effect.set_rotation(downVector.angle_to((closestPlanet.gravityCenter.get_global_position() - get_global_position()).normalized()))
		var main = get_tree().current_scene
		main.add_child(effect)
		effect.global_position = $Position2D.global_position
		SoundManager.play_se("MeteorExplode.wav")
		queue_free()
