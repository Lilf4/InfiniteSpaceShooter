class_name AbilityBase extends Node3D

var expireTime: float = 10
var abilityValues: AbilityResource

enum effectType{
	healing,
	cloaking,
	emp
}

@onready var DistortionSphere: MeshInstance3D = $DistortienSphere
@onready var AbilityIcon: MeshInstance3D = $AbilityIcon

@onready var Particle: GPUParticles3D = $PickupParticles
@onready var OmniLight: OmniLight3D = $OmniLight3D
@onready var ExpireTimer: Timer = $Timer

func init(ability: AbilityResource):
	abilityValues = ability
	DistortionSphere.mesh.surface_get_material(0).set_shader_parameter("tintColor", abilityValues.Tint)
	
	Particle.draw_pass_1.surface_get_material(0).set("albedo_color", Color(abilityValues.Tint, 0.1))
	Particle.draw_pass_1.surface_get_material(0).set("emission", abilityValues.Tint)
	
	AbilityIcon.get_surface_override_material(0).set("albedo_texture", abilityValues.Icon)
	
	OmniLight.light_energy = abilityValues.LightEnergy
	ExpireTimer.start(expireTime)
	pass

func _on_area_3d_body_entered(body):
	DistortionSphere.hide()
	AbilityIcon.hide()
	Particle.emitting = true
	applyEffect(body)

func applyEffect(player):
	match abilityValues.Effect:
		effectType.healing:
			player.heal(abilityValues.EffectValue)
			pass
		effectType.cloaking:
			pass
		effectType.emp:
			for enemy in System_Global.EnemyInstances:
				if position.distance_to(System_Global.EnemyInstances[enemy].position) <= 500:
					System_Global.EnemyInstances[enemy].applyEMP(abilityValues.EffectValue, (position.distance_to(System_Global.EnemyInstances[enemy].position) / 500) + 0.2)

func _on_gpu_particles_3d_finished():
	queue_free()
	pass

func _on_timer_timeout():
	queue_free()
	pass
