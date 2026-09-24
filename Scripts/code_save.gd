extends CodeEdit

@onready var menu_handler: Node = $"../../../MenuHandler"

var labels: Array[String] = []
var label_pos: Array[int] = []
var errors: Dictionary[int, String] = {}
var path: String = ""

func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey and event.ctrl_pressed:
		get_viewport().set_input_as_handled()
