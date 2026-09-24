@icon("res://Assets/Icons/list_unordered.svg")
extends Node

const CODE_EDIT = preload("uid://b40l36102l2ch")

@onready var tab_container: TabContainer = $"../VSplitContainer/TabContainer"
@onready var file_picker: FileDialog = $"../FilePicker"
@onready var file_saver: FileDialog = $"../FileSaver"
@onready var confirmation: ConfirmationDialog = $"../Confirmation"
@onready var main: Control = $".."
@onready var errors: RichTextLabel = $"../VSplitContainer/HSplitContainer/ErrorsContainer/VBoxContainer/MarginContainer/Errors"
@onready var symbols: RichTextLabel = $"../VSplitContainer/HSplitContainer/SymbolsContainer/VBoxContainer/MarginContainer/Symbols"
@onready var parse_timer: Timer = $"../ParseTimer"

@export var shortcuts: Dictionary[String, Shortcut]
var highlighter: CodeHighlighter:
	set(value):
		highlighter = value
		for child: CodeEdit in tab_container.get_children():
			child.syntax_highlighter = highlighter.duplicate()
var paths: Array[String] = []
var saved: Array[bool] = []
var tab: int = -1
var text_size: int = 14
var action: String = ""

func _ready() -> void:
	_on_file_id_pressed(0)
	$"../MenuBar/File".set_item_shortcut(0, shortcuts["new"])
	$"../MenuBar/File".set_item_shortcut(1, shortcuts["open"])
	$"../MenuBar/File".set_item_shortcut(2, shortcuts["save"])
	$"../MenuBar/File".set_item_shortcut(3, shortcuts["saveas"])
	$"../MenuBar/File".set_item_shortcut(4, shortcuts["close"])
	$"../MenuBar/Edit".set_item_shortcut(3, shortcuts["find"])
	$"../MenuBar/Edit".set_item_shortcut(4, shortcuts["replace"])
	$"../MenuBar/View".set_item_shortcut(1, shortcuts["zoomin"], true)
	$"../MenuBar/View".set_item_shortcut(2, shortcuts["zoomout"], true)
	$"../MenuBar/View".set_item_shortcut(3, shortcuts["zoomreset"])
	$"../MenuBar/Run".set_item_shortcut(0, shortcuts["build"])

func _on_tab_container_tab_selected(new_tab: int) -> void:
	tab = new_tab
	set_errors(tab_container.get_current_tab_control())
	set_symbols(tab_container.get_current_tab_control())

func _on_tab_container_active_tab_rearranged(idx_to: int) -> void:
	var path = paths.pop_at(tab)
	paths.insert(idx_to, path)
	var save = saved.pop_at(tab)
	saved.insert(idx_to, save)
	_on_tab_container_tab_selected(idx_to)

func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			paths.append("")
			saved.append(false)
			var code: CodeEdit = CODE_EDIT.instantiate()
			if highlighter:
				code.syntax_highlighter = highlighter.duplicate()
			code.add_comment_delimiter(";", "")
			code.text_changed.connect(_on_code_text_changed)
			code.gui_input.connect(main._on_code_gui_input.bind(code))
			tab_container.add_child(code)
			tab_container.set_tab_title(paths.size() - 1, "New File ●")
		1:
			file_picker.popup_file_dialog()
		2:
			if paths[tab] == "":
				_on_file_id_pressed(3)
			else:
				var file := FileAccess.open(paths[tab], FileAccess.WRITE)
				file.store_string(tab_container.get_current_tab_control().text)
				file.close()
				saved[tab] = true
				tab_container.set_tab_title(tab, paths[tab].get_file())
		3:
			file_saver.popup()
		4:
			if saved[tab]:
				paths.remove_at(tab)
				saved.remove_at(tab)
				tab_container.get_current_tab_control().queue_free()
				return
			action = "close"
			confirmation.popup()

func _on_file_picker_file_selected(path: String) -> void:
	if path in paths:
		tab_container.current_tab = paths.find(path)
		return
	var file := FileAccess.get_file_as_string(path)
	paths.append(path)
	saved.append(true)
	var code: CodeEdit = CODE_EDIT.instantiate()
	code.text = file
	code.path = path
	code.syntax_highlighter = highlighter.duplicate()
	code.add_comment_delimiter(";", "")
	code.text_changed.connect(_on_code_text_changed)
	code.gui_input.connect(main._on_code_gui_input.bind(code))
	tab_container.add_child(code)
	tab_container.set_tab_title(paths.size() - 1, path.get_file())
	tab_container.current_tab = paths.size() - 1
	Compiler.parse_code(code)
	set_errors(code)
	set_symbols(code)

func _on_file_saver_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(tab_container.get_current_tab_control().text)
	file.close()
	paths[tab] = path
	saved[tab] = true
	tab_container.get_current_tab_control().path = path
	tab_container.set_tab_title(tab, path.get_file())

func _on_edit_id_pressed(id: int) -> void:
	match id:
		0:
			tab_container.get_current_tab_control().undo()
		1:
			tab_container.get_current_tab_control().redo()

func _on_view_id_pressed(id: int) -> void:
	match id:
		1:
			text_size += 2
			if text_size >= 30:
				$"../MenuBar/View".set_item_disabled(1, true)
			elif text_size > 10:
				$"../MenuBar/View".set_item_disabled(2, false)
			set_zoom(text_size)
		2:
			text_size -= 2
			if text_size <= 10:
				$"../MenuBar/View".set_item_disabled(2, true)
			elif text_size < 30:
				$"../MenuBar/View".set_item_disabled(1, false)
			set_zoom(text_size)
		3:
			text_size = 14
			$"../MenuBar/View".set_item_disabled(1, false)
			$"../MenuBar/View".set_item_disabled(2, false)
			set_zoom(text_size)
		5:
			$"../MenuBar/View".toggle_item_checked(5)
			$"../VSplitContainer/HSplitContainer/ErrorsContainer".visible = $"../MenuBar/View".is_item_checked(5)
		6:
			$"../MenuBar/View".toggle_item_checked(6)
			$"../VSplitContainer/HSplitContainer/SymbolsContainer".visible = $"../MenuBar/View".is_item_checked(6)
		7:
			$"../MenuBar/View".toggle_item_checked(7)
			$"../VSplitContainer/HSplitContainer/ConsoleContainer".visible = $"../MenuBar/View".is_item_checked(7)
	for child in $"../VSplitContainer/HSplitContainer".get_children():
		if child.visible:
			$"../VSplitContainer/HSplitContainer".show()
			return
	$"../VSplitContainer/HSplitContainer".hide()

func _on_run_id_pressed(id: int) -> void:
	match id:
		0:
			if not saved[tab]:
				_on_file_id_pressed(2)
				if not saved[tab]:
					print("return")
					return
			var error := Compiler.compile(tab_container.get_current_tab_control())
			if error != 0:
				Console.newline()
				Console.error("Compilation failed with errors.", false)

func _on_confirmation_confirmed() -> void:
	match action:
		"close":
			if tab != -1:
				paths.remove_at(tab)
				saved.remove_at(tab)
				tab_container.get_current_tab_control().queue_free()

func _on_meta_clicked(meta: Variant) -> void:
	var idx: int = paths.find(str(meta.split(":")[0]))
	if idx == -1: return
	var code_edit: CodeEdit = tab_container.get_tab_control(idx)
	tab_container.current_tab = idx
	var line: int = str(meta.split(":")[-1]).to_int()
	code_edit.grab_focus()
	code_edit.set_caret_line(line)
	code_edit.set_caret_column(code_edit.get_line(line).length())

func _on_auto_scroll_toggled(toggled_on: bool) -> void:
	Console.set_auto_scroll(toggled_on)

func _on_code_text_changed() -> void:
	if saved[tab]:
		saved[tab] = false
		tab_container.set_tab_title(tab, tab_container.get_tab_title(tab) + " ●")
	parse_timer.start()

func _on_parse_timer_timeout() -> void:
	var code_edit: CodeEdit = tab_container.get_current_tab_control()
	Compiler.parse_code(code_edit)
	set_errors(code_edit)
	set_symbols(code_edit)



func set_errors(code_edit: CodeEdit) -> void:
	errors.clear()
	for error in code_edit.errors.keys():
		errors.append_text("	[color=#ff4939ff][url=" + code_edit.path + ":" + str(error) + "]Line " + str(error + 1) + ": " + code_edit.errors[error] + "[/url][/color]\n")

func set_symbols(code_edit: CodeEdit) -> void:
	symbols.clear()
	symbols.append_text("Labels (" + str(code_edit.labels.size()) + "):\n")
	for label_idx: int in range(code_edit.labels.size()):
		symbols.append_text("	[url=" + code_edit.path + ":" + str(code_edit.label_pos[label_idx]) + "]Line " + str(code_edit.label_pos[label_idx] + 1) + ": " + code_edit.labels[label_idx] + "[/url]")

func set_zoom(size: int) -> void:
	$"../MenuBar/View".set_item_text(0, " Zoom: " + str(size) + "px ")
	for child: CodeEdit in tab_container.get_children():
		child.add_theme_font_size_override("font_size", size)
		$"../VSplitContainer/HSplitContainer/ErrorsContainer/VBoxContainer/MarginContainer/Errors".add_theme_font_size_override("normal_font_size", size)
		$"../VSplitContainer/HSplitContainer/SymbolsContainer/VBoxContainer/MarginContainer/Symbols".add_theme_font_size_override("normal_font_size", size)
		$"../VSplitContainer/HSplitContainer/ConsoleContainer/VBoxContainer/MarginContainer/Console".add_theme_font_size_override("normal_font_size", size)
