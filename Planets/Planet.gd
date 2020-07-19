extends StaticBody2D

export var givenSize = 0
var planetSize
var gravity
var planet_colour
var planet_colour_palette = Global.palettes
export (Color) var atmosphere = Color(.37, .62, .9, .15)

onready var gravityCenter = $GravityCenter
onready var planetCollision = $CollisionShape2D
onready var gravityArea = $GravityArea
onready var gravityCollision = $GravityArea/GravityCollision
var gravityEffectField 
var randomSpots
var craters = []
var numOfCraters
var craterSize = []

func _ready():
	randomize()
	if givenSize == 0:
		planetSize = rand_range(100, 300)
	else:
		planetSize = givenSize
	gravity = planetSize + 200
	var paletteNumber = randi()%4

	match paletteNumber:
		0:
			planet_colour = planet_colour_palette[0]
		1:
			planet_colour = planet_colour_palette[1]
		2:
			planet_colour = planet_colour_palette[2]
		3:
			planet_colour = planet_colour_palette[3]
		4:
			planet_colour = planet_colour_palette[4]
		_:
			planet_colour = planet_colour_palette[0]
	
	planet_colour.h = planet_colour.h + Global.hueShift
	gravityEffectField = gravity
	planetCollision.get_shape().set_radius(planetSize)
	gravityCollision.get_shape().set_radius(gravity)
	numOfCraters = randi()%8+4
	createListOfCraters()
	update()
	

func _draw():
	draw_circle(gravityCenter.get_position(), planetSize, planet_colour)

	draw_circle(gravityCenter.get_position(), gravityEffectField, atmosphere)
	for i in range(numOfCraters):
		draw_circle(craters[i], craterSize[i], planet_colour+Color(.2,.2,.2,0))

func createListOfCraters():
	var craterCoordsX
	var craterCoordsY
	for i in range(numOfCraters):
		if gravityCenter.get_position().x > 0:
			craterCoordsX = gravityCenter.get_position().x + rand_range(-planetSize / 2, planetSize / 2) 
		else:
			craterCoordsX = gravityCenter.get_position().x - rand_range(-planetSize / 2, planetSize / 2) 
		if gravityCenter.get_position().y > 0:
			craterCoordsY = gravityCenter.get_position().y + rand_range(-planetSize / 2, planetSize / 2) 
		else:
			craterCoordsY = gravityCenter.get_position().y - rand_range(-planetSize / 2, planetSize / 2) 
		craters.push_back(Vector2(craterCoordsX, craterCoordsY))
		craterSize.push_back(rand_range(10,40))
	

func is_in_gravity_field(pos):
	return gravityCenter.get_global_position().distance_to(pos) <= gravityEffectField
