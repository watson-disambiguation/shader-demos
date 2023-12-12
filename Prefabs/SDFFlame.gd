extends Node3D

@onready var mesh = $MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready():
	var mat: ShaderMaterial = mesh.get_active_material(0)
	mat = mat.duplicate()
	mesh.set_surface_override_material(0,mat)
	var noise_tex = NoiseTexture3D.new()
	noise_tex.seamless = true
	noise_tex.seamless_blend_skirt = 0.7
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05
	noise.seed = randi()
	noise_tex.noise = noise
	mat.set_shader_parameter("noiseTex",noise_tex)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
