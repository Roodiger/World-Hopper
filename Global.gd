extends Node

var closestPlanet
var playerHealth: int = 1
var score = 0
var dashing = false
var jumping = false
var muteText = "mute"
var palettes = randomizePalette()
var hueShift
var buttonDisabled = false

signal no_health

func _ready():
	SilentWolf.configure({
		"api_key": "HsJtT5Kq8W9ViYtzHPV9P8FeDR9uZrIpaYRplVeu",
		"game_id": "WorldHopper",
		"game_version": "0.0.0",
		"log_level": 1
	})
	
	SilentWolf.configure_scores({
		"open_scene_on_close": "res://scenes/Splash.tscn"
	})
	
	palettes = randomizePalette()

func _process(delta):
	if playerHealth < 1:
		if get_tree().get_nodes_in_group("Player").size() > 0:
			connect("no_health", get_tree().get_current_scene().get_node("Player"), "_on_Global_no_health")
			emit_signal("no_health")

	if get_tree().current_scene.get_name() == "World" && playerHealth < 1:
		get_tree().get_root().get_node("World/UI/TimerLabel").set_text("")

func reset():
	playerHealth = 1
	score = 0

func randomizePalette():
	randomize()
	hueShift = rand_range(-.05,.05)
	var choice = randi()%9
	match choice:
		0:
			return [Color("D5C4D8"), Color("8FAFA8"), Color("667E63"), Color("433D35"), Color("6E6C45")]
		1:
			return [Color("9B7583"), Color("352F36"), Color("4D608F"), Color("88B5DE"), Color("C6E2CF")]
		2:
			return [Color("5B3F87"), Color("232936"), Color("30474D"), Color("45665C"), Color("596362")]
		3:
			return [Color("20131F"), Color("533E5C"), Color("615A66"), Color("5A6255"), Color("997F54")]
		4:
			return [Color("9EA89D"), Color("779484"), Color("83483E"), Color("181B1F"), Color("3B584E")]
		5:
			return [Color("1EADBB"), Color("4B7A74"), Color("1F5F93"), Color("544C4E"), Color("C04B43")]
		6:
			return [Color("72806A"), Color("6E5E41"), Color("2D2437"), Color("2D4E51"), Color("5C6CA7")]
		7:
			return [Color("292121"), Color("364356"), Color("5D5A6E"), Color("A17252"), Color("715733")]
		8:
			return [Color("5A8B92"), Color("326F57"), Color("2B3B4C"), Color("9E6639"), Color("CEA158")]
		9:
			return [Color("2E2C33"), Color("607F42"), Color("709B6C"), Color("B9CEAC"), Color("237F8E")]
		_:
			return [Color("2E2C33"), Color("607F42"), Color("709B6C"), Color("B9CEAC"), Color("237F8E")]
