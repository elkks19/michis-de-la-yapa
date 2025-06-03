extends SubViewportContainer

@onready var vw = $jacobitaViewport

func _ready():
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if event is InputEventMouse:
		var mouseEvent = event.duplicate()
		mouseEvent.position = get_global_transform_with_canvas().affine_inverse() * event.position
		vw.push_input(mouseEvent)

	else:
		vw.push_input(event)
