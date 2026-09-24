class_name TreeViewColumn
extends RefCounted

enum Type {
	# Valid for all FileStatistics classes
	FILE_PATH,
	FILE_NAME,
	FILE_SIZE,
	FILE_TYPE,
	FILE_TOTAL_LINES,
	FILE_CODE_LINES,
	FILE_COMENT_LINES,
	FILE_BLANK_LINES,
	FILE_EXTENSION,
	FILE_ICON,
	FILE_COLOR,
	FILE_IS_SCRIPT,
	FILE_IS_SCENE,
	FILE_IS_RESOURCE,

	# Valid only for ResourceStatistics
	SCENE_BASE_NODE_TYPE,
	SCENE_NODE_COUNT,
	SCENE_NODE_CONNECTION_COUNT,
	RESOURCE_LOCAL_TO_SCENE,
}

@export var label: String
@export var type: Type


func _init(new_label: String = "", new_type: Type = Type.FILE_NAME) -> void:
	label = new_label
	type = new_type


func get_column_icon(file: FileStatistics) -> Texture2D:
	match type:
		Type.FILE_NAME:
			return _get_icon(file.file_icon)

	if file is ResourceStatistics:
		match type:
			Type.SCENE_BASE_NODE_TYPE:
				@warning_ignore("unsafe_property_access", "unsafe_call_argument")
				return _get_icon(file.scene_base_node_type)

	return null


func get_column_tooltip(file: FileStatistics) -> String:
	match type:
		Type.FILE_NAME:
			return file.file_path

	return ""


func get_column_text(file: FileStatistics) -> String:
	match type:
		Type.FILE_NAME:
			return file.file_name
		Type.FILE_SIZE:
			return String.humanize_size(file.file_size)
		Type.FILE_TYPE:
			return file.file_type
		Type.FILE_TOTAL_LINES:
			return str(file.file_total_lines)
		Type.FILE_CODE_LINES:
			return str(file.file_code_lines)
		Type.FILE_COMENT_LINES:
			return str(file.file_comment_lines)
		Type.FILE_BLANK_LINES:
			return str(file.file_blank_lines)

	if file is ResourceStatistics:
		match type:
			Type.SCENE_BASE_NODE_TYPE:
				@warning_ignore("unsafe_property_access")
				return file.scene_base_node_type if file.scene_base_node_type else "Unknown"
			Type.SCENE_NODE_COUNT:
				@warning_ignore("unsafe_property_access")
				return str(file.scene_node_count)
			Type.SCENE_NODE_CONNECTION_COUNT:
				@warning_ignore("unsafe_property_access")
				return str(file.scene_connection_count)
			Type.RESOURCE_LOCAL_TO_SCENE:
				@warning_ignore("unsafe_property_access")
				return str(file.resource_local_to_scene)

	return "Error"


func _get_icon(icon_path: String) -> Texture2D:
	if EditorInterface.get_base_control().has_theme_icon(icon_path, "EditorIcons"):
		return EditorInterface.get_base_control().get_theme_icon(icon_path, "EditorIcons")
	if ResourceLoader.exists(icon_path):
		return ResourceLoader.load(icon_path)

	return null


func custom_sort(a: FileStatistics, b: FileStatistics, reverse: bool) -> bool:
	match type:
		Type.FILE_PATH:
			return _sort_string(a.file_path, b.file_path, reverse)
		Type.FILE_NAME:
			return _sort_string(a.file_name, b.file_name, reverse)
		Type.FILE_SIZE:
			return _sort_int(a.file_size, b.file_size, reverse)
		Type.FILE_TYPE:
			return _sort_string(a.file_type, b.file_type, reverse)
		Type.FILE_TOTAL_LINES:
			return _sort_int(a.file_total_lines, b.file_total_lines, reverse)
		Type.FILE_CODE_LINES:
			return _sort_int(a.file_code_lines, b.file_code_lines, reverse)
		Type.FILE_COMENT_LINES:
			return _sort_int(a.file_comment_lines, b.file_comment_lines, reverse)
		Type.FILE_BLANK_LINES:
			return _sort_int(a.file_blank_lines, b.file_blank_lines, reverse)
		Type.FILE_EXTENSION:
			return _sort_string(a.file_extension, b.file_extension, reverse)
		Type.FILE_ICON:
			return _sort_string(a.file_icon, b.file_icon, reverse)
		Type.FILE_COLOR:
			return false
		Type.FILE_IS_SCRIPT:
			return _sort_string(str(a.file_is_script), str(b.file_is_script), reverse)
		Type.FILE_IS_SCENE:
			return _sort_string(str(a.file_is_scene), str(b.file_is_scene), reverse)
		Type.FILE_IS_RESOURCE:
			return _sort_string(str(a.file_is_resource), str(b.file_is_resource), reverse)

	if a is ResourceStatistics and b is ResourceStatistics:
		@warning_ignore_start("unsafe_property_access", "unsafe_call_argument")
		match type:
			Type.SCENE_BASE_NODE_TYPE:
				return _sort_string(a.scene_base_node_type, b.scene_base_node_type, reverse)
			Type.SCENE_NODE_COUNT:
				return _sort_int(a.scene_node_count, b.scene_node_count, reverse)
			Type.SCENE_NODE_CONNECTION_COUNT:
				return _sort_int(a.scene_connection_count, b.scene_connection_count, reverse)
			Type.RESOURCE_LOCAL_TO_SCENE:
				return _sort_string(str(a.resource_local_to_scene), str(b.resource_local_to_scene), reverse)
		@warning_ignore_restore("unsafe_property_access", "unsafe_call_argument")

	return false


func _sort_string(a: String, b: String, reverse: bool) -> bool:
	if reverse:
		return a.nocasecmp_to(b) == 1
	return a.nocasecmp_to(b) == -1


func _sort_int(a: int, b: int, reverse: bool) -> bool:
	if reverse:
		return a > b
	return a < b
