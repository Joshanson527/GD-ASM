extends CodeEdit


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_S and (event.ctrl_pressed or event.meta_pressed):
			accept_event()
			$"../../.."._on_save_pressed()
