extends Node3D

@onready var camera: Camera3D = $Camera3D
@export var target: Vector3
@export var rotation_speed: float
@export var zoom_speed: float
@export var min_dist: float
@export var max_dist: float
@export var bottom_angle: float = 0
@export var top_angle: float = 89

var angle_above : float = 0:
	set(value):
		angle_above = clampf(value,bottom_angle,top_angle)

var angle_around : float = 0:
	set(value): 
		angle_around = fmod(value,360)
		
var dist : float = 5:
	set(value):
		dist = clampf(value,min_dist,max_dist)

func _ready():
	position()
		
func position():
	var around_rad = deg_to_rad(angle_around)
	var above_rad =  deg_to_rad(angle_above)
	var x = cos(around_rad)
	var y = sin(above_rad)
	var z = sin(around_rad)
	var offset = Vector3(x,y,z) * dist
	set_position(offset + target)
	camera.look_at(target)

func _process(delta):
	if Input.is_anything_pressed():
		angle_around += Input.get_axis("ui_left","ui_right") * delta * rotation_speed
		angle_above += Input.get_axis("ui_down","ui_up") * delta * rotation_speed
		dist += Input.get_axis("ui_in","ui_out") * delta * zoom_speed
		position()
	
	
