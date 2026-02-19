extends PanelContainer
class_name DraggablePanelContainer

var dragging := false
var drag_offset := Vector2.ZERO
var is_focused: bool = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		var pc := get_tree().get_first_node_in_group("pc_control") as PCControl
		if pc:
			pc.request_focus(self)

		dragging = true
		drag_offset = event.position


	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

		dragging = false


	elif event is InputEventMouseMotion and dragging:

		position += event.relative

		# Limites da viewport
		var viewport_size = get_viewport().size

		# Altura da taskbar (ajuste se mudar depois)
		var taskbar_height := 30.0

		position.x = clamp(
			position.x,
			0,
			viewport_size.x - size.x
		)

		position.y = clamp(
			position.y,
			0,
			viewport_size.y - size.y - taskbar_height
		)
