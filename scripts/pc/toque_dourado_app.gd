extends WindowBase
class_name ToqueDeMidasApp

@onready var particles: GPUParticles2D = $Content/Lens/GoldParticles
@onready var lens: Control = $Content/Lens

var effect_finished := false
const REVEAL_DURATION := 1.8
const REVEAL_COVERAGE_THRESHOLD := 0.90

var reveal_timers: Dictionary = {}
var mirrors: Dictionary = {}

var mirror_shader := preload("res://scripts/shaders/mirror_clip.gdshader")

func _ready():
	super._ready()
	lens.clip_contents = true
	if particles:
		particles.one_shot = false
		particles.emitting = true

func _process(delta):
	_update_lens(delta)

func _update_lens(delta: float):
	var lens_rect = lens.get_global_rect()
	var hidden_icons = get_tree().get_nodes_in_group("hidden_icons")
	var blocking_rects = _get_blocking_window_rects()
	
	var shader_rects: Array[Vector4] = []
	for r in blocking_rects:
		shader_rects.append(Vector4(r.position.x, r.position.y, r.size.x, r.size.y))
	while shader_rects.size() < 8:
		shader_rects.append(Vector4(0, 0, 0, 0))
	
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
			var mat = ShaderMaterial.new()
			mat.shader = mirror_shader
			mirror.material = mat
			lens.add_child(mirror)
			mirrors[icon] = mirror
		
		var mirror: TextureRect = mirrors[icon]
		mirror.position = icon_rect.position - lens_rect.position
		mirror.size = icon_rect.size
		
		var mat := mirror.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("window_rects", shader_rects)
			mat.set_shader_parameter("window_count", blocking_rects.size())
		
		if lens_rect.intersects(icon_rect):
			var intersection = lens_rect.intersection(icon_rect)
			var coverage = (intersection.size.x * intersection.size.y) / (icon_rect.size.x * icon_rect.size.y)
			mirror.modulate.a = clamp(coverage, 0.0, 1.0)

			if coverage >= REVEAL_COVERAGE_THRESHOLD and not effect_finished:
				if _icon_blocked_by_window(icon_rect):
					reveal_timers[icon] = 0.0
				else:
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

func _get_blocking_window_rects() -> Array:
	var rects: Array = []
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if not pc:
		return rects
	for window in pc.open_windows.values():
		if window == self or window.is_minimized:
			continue
		rects.append(window.get_global_rect())
		if rects.size() >= 8:
			break
	return rects

func _icon_blocked_by_window(icon_rect: Rect2) -> bool:
	var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
	if not pc:
		return false
	for window in pc.open_windows.values():
		if window == self or window.is_minimized:
			continue
		if window.get_global_rect().intersects(icon_rect):
			return true
	return false

func _trigger_finish_effect():
	if effect_finished:
		return
	effect_finished = true
	
	if not particles:
		return
	
	var mat := particles.process_material as ParticleProcessMaterial
	
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
