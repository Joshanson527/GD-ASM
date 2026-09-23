@icon("res://Assets/Icons/list_unordered.svg")
extends Node

const CODE_EDIT = preload("uid://b40l36102l2ch")

@onready var tab_container: TabContainer = $"../VSplitContainer/TabContainer"
@onready var file_picker: FileDialog = $"../FilePicker"
@onready var file_saver: FileDialog = $"../FileSaver"
@onready var confirmation: ConfirmationDialog = $"../Confirmation"
@onready var main: Control = $".."

var state: String = ""
var paths: Array[String] = [""]

func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			pass
		1:
			state = "open"
			file_picker.popup_file_dialog()

func _on_edit_id_pressed(id: int) -> void:
	pass

func _on_view_id_pressed(id: int) -> void:
	pass

func _on_run_id_pressed(id: int) -> void:
	pass

func _on_file_picker_file_selected(path: String) -> void:
	match state:
		"open":
			var file := FileAccess.get_file_as_string(path)
			paths.append(path)
			var code: CodeEdit = CODE_EDIT.instantiate()
			code.name = "New 1"
			code.text = file
			code.text_changed.connect()
