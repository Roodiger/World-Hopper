extends KinematicBody2D

var direction = 1

var speed = Vector2()
var velocity = Vector2()
var state

var dash_cool_down_right = 0
var dash_button_count_right = 0
var dash_cool_down_left = 0
var dash_button_count_left = 0
var dashReady = true


var MAX_SPEED = 20000
const JUMP_FORCE = 20000
enum {
	MOVE,
	JUMP,
	FALL
}
signal game_over

func _ready():
	 
	set_physics_process(true)
	Global.closestPlanet = get_closest_planet()
	state = MOVE

func _physics_process(delta):
	
	if (dash_cool_down_right > 0):
		dash_cool_down_right = dash_cool_down_right - 1 * delta
	else:
		dash_button_count_right = 0
		
	if (dash_cool_down_left > 0):
		dash_cool_down_left = dash_cool_down_left - 1 * delta
	else:
		dash_button_count_left = 0
		
	match state:
		MOVE:
			applyMovement(delta)
		JUMP:
			applyJump(delta)
		FALL:
			applyFall(delta)
	var nextPlanet = get_closest_planet()
	
	if(nextPlanet != Global.closestPlanet && nextPlanet.is_in_gravity_field(get_global_position()) && $GravityTimer.time_left == 0):
		Global.closestPlanet = nextPlanet
		$GravityTimer.start(.5)
		Global.jumping = false
		state = FALL

	applyGravity(delta)
	
	var playerRot = get_player_rotation()
	
	velocity = Vector2(speed.x * delta, speed.y * delta)
	velocity = velocity.rotated(playerRot)
	
	move_and_slide(velocity)
	set_rotation(playerRot)
	if is_on_wall():
		speed.y = 0


func applyMovement(delta):
	
	if (Input.is_action_just_pressed("ui_right")):
		if (dash_cool_down_right > 0 && dash_button_count_right == 1 && dashReady == true  && Global.dashing == false): 
			Global.dashing = true
			MAX_SPEED = MAX_SPEED * 2
			get_node("Sprite").modulate = Color(10,10,10,10)
			yield(get_tree().create_timer(.25),"timeout")
			get_node("Sprite").modulate = Color(1,1,1,1)
			yield(get_tree().create_timer(.25),"timeout")
			get_node("Sprite").modulate = Color(10,10,10,10)
			yield(get_tree().create_timer(.25),"timeout")
			get_node("Sprite").modulate = Color(1,1,1,1)
			Global.dashing = false
			MAX_SPEED = MAX_SPEED /2
			dashReady = false
			yield(get_tree().create_timer(.5),"timeout")
			dashReady = true
		else:
			Global.dashing = false
			dash_cool_down_right = 0.5
			dash_button_count_right = dash_button_count_right + 1
			
	if (Input.is_action_just_pressed("ui_left")):
		if (dash_cool_down_left > 0 && dash_button_count_left == 1 && dashReady == true  && Global.dashing == false): 
			Global.dashing = true
			MAX_SPEED = MAX_SPEED * 2
			get_node("Sprite").modulate = Color(10,10,10,10)
			yield(get_tree().create_timer(.25),"timeout")
			get_node("Sprite").modulate = Color(1,1,1,1)
			yield(get_tree().create_timer(.25),"timeout")
			get_node("Sprite").modulate = Color(10,10,10,10)
			yield(get_tree().create_timer(.25),"timeout")
			get_node("Sprite").modulate = Color(1,1,1,1)
			Global.dashing = false
			MAX_SPEED = MAX_SPEED /2
			dashReady = false
			get_tree().create_timer(.5)
			dashReady = true
		else:
			Global.dashing = false
			dash_cool_down_left = 0.5
			dash_button_count_left = dash_button_count_left + 1

	if Input.is_action_pressed("ui_left"):
		$AnimationPlayer.play("Walk")
		$Sprite.flip_h = true
		direction = -1
		speed.x = MAX_SPEED * direction
	elif Input.is_action_pressed("ui_right"):
		$Sprite.flip_h = false
		$AnimationPlayer.play("Walk")
		direction = 1
		speed.x = MAX_SPEED * direction
	else:
		$AnimationPlayer.stop()
		speed.x = speed.x / 1.1
	
	if Input.is_action_just_pressed("ui_up") && is_on_wall():
		SoundManager.play_se("Jump.wav")
		Global.jumping = true
		state = JUMP

func applyGravity(delta):
	if(Global.closestPlanet != null && Global.closestPlanet.is_in_gravity_field(get_global_position())):
		speed.y += Global.closestPlanet.gravity
	else:
		get_closest_planet()

func applyJump(delta):
		speed.x = 0
		speed.y = -JUMP_FORCE
		if $DeathTimer.is_stopped():
			$DeathTimer.start(3)


func applyFall(delta):
		$DeathTimer.stop()
		speed.y = JUMP_FORCE
		applyMovement(delta)
		if is_on_wall():
			state = MOVE

func get_player_rotation():
	var downVector = Vector2(0,1)
	if(Global.closestPlanet != null):
		return downVector.angle_to(get_gravity_vector(Global.closestPlanet))
	else:
		return get_rotation()

func get_gravity_vector(planet):
	return (planet.gravityCenter.get_global_position() - get_global_position()).normalized()

func get_closest_planet():
	var distance = -1
	var foundPlanet = null
	
	for planet in get_tree().get_nodes_in_group("Planets"):
		if(planet.gravityCenter):
			if(distance < 0):
				foundPlanet = planet
				distance = planet.gravityCenter.get_global_position().distance_to(get_global_position())
			elif(distance > planet.gravityCenter.get_global_position().distance_to(get_global_position())):
				foundPlanet = planet
				distance = planet.gravityCenter.get_global_position().distance_to(get_global_position())
	
	return foundPlanet

func _on_Button_planet_exploded(value):
	if value.is_in_gravity_field(get_global_position()):
		Global.playerHealth = Global.playerHealth - 1
	else:
		Global.score = Global.score + 1
		$"/root/World/UI/Score".set_text("Score: " + str(Global.score))
		$"/root/World/UI/TimerLabel".set_text("")

func _on_Global_no_health():
	emit_signal("game_over")
	queue_free()


func _on_DeathTimer_timeout():
	Global.playerHealth = Global.playerHealth - 1
