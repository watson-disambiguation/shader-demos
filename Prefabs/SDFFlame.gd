extends Node3D

@onready var mesh = $MeshInstance3D
@onready var light = $OmniLight3D
@export var default_color: Vector3
@export var color_speed: float
var curr_color: Vector3
var mat: ShaderMaterial
# Called when the node enters the scene tree for the first time.
func _ready():
	var old_mat: ShaderMaterial = mesh.get_active_material(0)
	mat = old_mat.duplicate()
	var old_noise_tex = mat.get_shader_parameter("noiseTex");
	var old_noise = old_noise_tex.noise
	mesh.set_surface_override_material(0,mat)
	var noise_tex = old_noise_tex.duplicate()
	var noise = old_noise.duplicate()
	noise.seed = randi()
	noise_tex.noise = noise
	mat.set_shader_parameter("noiseTex",noise_tex)
	curr_color = default_color
	set_color()

func ok_hsl(color: Vector3) -> Color:
	return Color.from_ok_hsl(color.x,color.y,color.z)

func set_color():
	var col = ok_hsl(curr_color)
	mat.set_shader_parameter("innerColor",ok_hsl(curr_color))
	light.light_color = col
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	curr_color.x += delta * color_speed
	curr_color.x = fmod(curr_color.x,1.)
	set_color()
