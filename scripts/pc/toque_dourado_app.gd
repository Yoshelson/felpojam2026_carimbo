extends WindowBase
class_name ToqueDeMidasApp

@onready var particles: GPUParticles2D = $Content/Lens/GoldParticles
@onready var lens: Control = $Content/Lens

var effect_finished := false
const REVEAL_DURATION := 1.8
const REVEAL_COVERAGE_THRESHOLD := 0.90

var reveal_timers: Dictionary = {}
var mirrors: Dictionary = {}

func _ready():
	super._ready()
	lens.clip_contents = true
	# Garante que partículas não ficam emitindo ao abrir a janela
	if particles:
		particles.emitting = false

func _process(delta):
	_update_lens(delta)

func _update_lens(delta: float):
	var lens_rect = lens.get_global_rect()
	var hidden_icons = get_tree().get_nodes_in_group("hidden_icons")

	for icon in mirrors.keys():
		if not hidden_icons.has(icon):
			mirrors[icon].queue_free()
			mirrors.erase(icon)

	for icon in hidden_icons:
		var icon_rect = icon.get_global_rect()

		if not mirrors.has(icon):
			var mirror = TextureRect.new()
			mirror.texture = icon.icon_texture
			mirror.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			mirror.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE
			lens.add_child(mirror)
			mirrors[icon] = mirror

		var mirror: TextureRect = mirrors[icon]
		var local_pos = icon_rect.position - lens_rect.position
		mirror.position = local_pos
		mirror.size = icon_rect.size

		if lens_rect.intersects(icon_rect):
			var intersection = lens_rect.intersection(icon_rect)
			var coverage = (intersection.size.x * intersection.size.y) / (icon_rect.size.x * icon_rect.size.y)
			mirror.modulate.a = clamp(coverage, 0.0, 1.0)

			if coverage >= REVEAL_COVERAGE_THRESHOLD and not effect_finished:
				reveal_timers[icon] = reveal_timers.get(icon, 0.0) + delta
				if reveal_timers[icon] >= REVEAL_DURATION:
					icon.reveal()
					reveal_timers.erase(icon)
					_trigger_finish_effect()
			else:
				reveal_timers[icon] = 0.0
		else:
			mirror.modulate.a = 0.0
			reveal_timers[icon] = 0.0

func _trigger_finish_effect():
	if effect_finished:
		return
	effect_finished = true

	if not particles:
		return

	var mat := particles.process_material as ParticleProcessMaterial
	if mat:
		mat.emission_box_extents = Vector3(341, 218, 1)
		mat.initial_velocity_min = 0.0
		mat.initial_velocity_max = 0.0
		mat.gravity = Vector3(0, 0, 0)
		mat.scale_min = 6.0
		mat.scale_max = 10.0
		mat.color = Color(1.0, 0.9, 0.2, 1.0)

	particles.one_shot = true
	particles.amount = 80
	particles.lifetime = 0.4
	particles.explosiveness = 1.0
	particles.emitting = true

	await get_tree().create_timer(0.15).timeout

	var t := 0.0
	while t < 1.0:
		t += get_process_delta_time() * 3.0
		if mat:
			mat.color = Color(1.0, 0.9, 0.2, 1.0 - t)
		await get_tree().process_frame

	particles.emitting = false
	particles.visible = false
	if mat:
		mat.color = Color(1.0, 0.9, 0.2, 1.0)
