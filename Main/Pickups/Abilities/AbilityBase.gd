extends Node3D

@export var Icon: Texture2D
@export var Tint: Color 

@onready var DistortionSphere: MeshInstance3D = $DistortienSphere
@onready var AbilityIcon: MeshInstance3D = $AbilityIcon

func _ready():
	init()

func init():
	var shader: ShaderMaterial = DistortionSphere.mesh.surface_get_material(0)
	shader.set_shader_parameter("tintColor", Tint)
	
	var iconMaterial: Material = AbilityIcon.get_surface_override_material(0)
	iconMaterial.set("albedo_texture", Icon)
	pass

func _on_area_3d_body_entered(body):
	pass # Replace with function body.

func applyEffect(player):
	pass
