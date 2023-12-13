extends Node3D

@onready var mesh = $MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready():
	var mat: ShaderMaterial = mesh.get_active_material(0)
	mat = mat.duplicate()
	var old_noise_tex = mat.get_shader_parameter("noiseTex");
	var old_noise = old_noise_tex.noise
	mesh.set_surface_override_material(0,mat)
	var noise_tex = old_noise_tex.duplicate()
	var noise = old_noise.duplicate()
	noise.seed = randi()
	noise_tex.noise = noise
	mat.set_shader_parameter("noiseTex",noise_tex)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
