extends SubViewportContainer

@onready var vw = $jacobitaViewport

func _ready():
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if event is InputEventMouse:
		var mouseEvent = event.duplicate()
		mouseEvent.position = get_global_transform_with_canvas().affine_inverse() * event.position
		vw.push_input(mouseEvent)

	elif event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		vw.push_input(event)
	else:
		vw.push_input(event)
