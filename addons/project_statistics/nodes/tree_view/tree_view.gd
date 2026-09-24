@tool
class_name TreeView
extends Tree

## This variable must be se before _ready() is called
var column_names: Array[TreeViewColumn]:
	set(new_column_names):
		column_names = new_column_names

		if is_node_ready():
			reload_title_row()
			reload_tree()

## This array will be resorted, provide copy of original array if it is not desired
var row_files: Array[FileStatistics]:
	set(new_row_files):
		row_files = new_row_files
		_column_sort_index = -1

		if column_names:
			reload_tree()

var _column_sort_index: int = -1
var _column_sort_reversed: bool


func _init() -> void:
	column_title_clicked.connect(_on_column_title_clicked)
	item_activated.connect(_on_item_activated)


func _ready() -> void:
	if column_names:
		reload_title_row()
		reload_tree()


func reload_title_row() -> void:
	columns = column_names.size()

	for column_index: int in range(column_names.size()):
		set_column_title(column_index, column_names[column_index].label)


func reload_tree() -> void:
	clear()

	var root: TreeItem = create_item()

	for file: FileStatistics in row_files:
		var item: TreeItem = create_item(root)

		for column_index: int in range(column_names.size()):
			item.set_icon_max_width(column_index, 16)
			item.set_icon(column_index, column_names[column_index].get_column_icon(file))
			item.set_text(column_index, column_names[column_index].get_column_text(file))
			item.set_tooltip_text(column_index, column_names[column_index].get_column_tooltip(file))

		item.set_metadata(0, file)


func _on_column_title_clicked(column: int, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		if column == _column_sort_index:
			_column_sort_reversed = not _column_sort_reversed
		else:
			_column_sort_index = column
			_column_sort_reversed = false

		row_files.sort_custom(
			func(a: FileStatistics, b: FileStatistics) -> bool:
				return column_names[_column_sort_index].custom_sort(a, b, _column_sort_reversed)
		)

		reload_tree()


func _on_item_activated() -> void:
	if get_selected_column() == 0:
		var selected_file: FileStatistics = get_selected().get_metadata(0)

		if Engine.is_editor_hint:
			EditorInterface.select_file(selected_file.file_path)

			if not ResourceLoader.exists(selected_file.file_path):
				return

			var resource: Resource = ResourceLoader.load(selected_file.file_path)

			if resource:
				if resource is PackedScene:
					EditorInterface.open_scene_from_path(selected_file.file_path)
				else:
					EditorInterface.edit_resource(resource)
