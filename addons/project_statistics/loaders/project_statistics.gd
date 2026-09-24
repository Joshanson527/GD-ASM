class_name ProjectStatistics
extends RefCounted

enum Category {
	SCENE,
	RESOURCE,
	SCRIPT,
	MISC,
}

var scenes: Array[FileStatistics]
var resources: Array[FileStatistics]
var scripts: Array[FileStatistics]
var misc: Array[FileStatistics]


func _init(
		ignored_paths: PackedStringArray = [],
		included_paths: PackedStringArray = [],
) -> void:
	_load_directory("res://", ignored_paths, included_paths)


func get_category(category: Category) -> Array[FileStatistics]:
	match category:
		Category.SCENE:
			return scenes
		Category.RESOURCE:
			return resources
		Category.SCRIPT:
			return scripts
		Category.MISC:
			return misc

	return []


func get_file_count_by_file_type(category: Category) -> Dictionary[String, int]:
	var dict: Dictionary[String, int] = { }

	for file: FileStatistics in get_category(category):
		if file.file_type in dict:
			dict[file.file_type] += 1
		else:
			dict[file.file_type] = 1

	return dict


func get_color_by_file_type(category: Category) -> Dictionary[String, Color]:
	var dict: Dictionary[String, Color] = { }

	for file: FileStatistics in get_category(category):
		if file.file_type not in dict:
			dict[file.file_type] = file.file_color

	return dict


func get_icon_by_file_type(category: Category) -> Dictionary[String, String]:
	var dict: Dictionary[String, String] = { }

	for file: FileStatistics in get_category(category):
		if file.file_type not in dict:
			dict[file.file_type] = file.file_icon

	return dict


func get_total_lines_by_file_type(category: Category) -> Dictionary[String, int]:
	var dict: Dictionary[String, int] = { }

	for file: FileStatistics in get_category(category):
		if file.file_type in dict:
			dict[file.file_type] += file.file_total_lines
		else:
			dict[file.file_type] = file.file_total_lines

	return dict


func get_total_size_by_file_type(category: Category) -> Dictionary[String, int]:
	var dict: Dictionary[String, int] = { }

	for file: FileStatistics in get_category(category):
		if file.file_type in dict:
			dict[file.file_type] += file.file_size
		else:
			dict[file.file_type] = file.file_size

	return dict


func get_file_types(category: Category) -> PackedStringArray:
	var file_types: PackedStringArray = []

	for file: FileStatistics in get_category(category):
		if file.file_type not in file_types:
			file_types.append(file.file_type)

	return file_types


func get_file_names(category: Category) -> PackedStringArray:
	var file_names: PackedStringArray = []

	for file: FileStatistics in get_category(category):
		if file.file_name not in file_names:
			file_names.append(file.file_name)

	return file_names


func get_file_extensions(category: Category) -> PackedStringArray:
	var file_extensions: PackedStringArray = []

	for file: FileStatistics in get_category(category):
		if file.file_extension not in file_extensions:
			file_extensions.append(file.file_extension)

	return file_extensions


func get_total_lines(category: Category) -> int:
	var total: int = 0

	for file: FileStatistics in get_category(category):
		total += file.file_total_lines

	return total


func get_total_size(category: Category) -> int:
	var total: int = 0

	for file: FileStatistics in get_category(category):
		total += file.file_size

	return total


func get_total_code_lines(category: Category) -> int:
	var total: int = 0

	for file: FileStatistics in get_category(category):
		total += file.file_code_lines

	return total


func get_total_comment_lines(category: Category) -> int:
	var total: int = 0

	for file: FileStatistics in get_category(category):
		total += file.file_comment_lines

	return total


func get_total_blank_lines(category: Category) -> int:
	var total: int = 0

	for file: FileStatistics in get_category(category):
		total += file.file_blank_lines

	return total


func get_total_scene_node_count(category: Category) -> int:
	var total: int = 0

	for file: FileStatistics in get_category(category):
		if file is ResourceStatistics:
			@warning_ignore("unsafe_property_access")
			total += file.scene_node_count

	return total


func get_total_scene_connection_count(category: Category) -> int:
	var total: int = 0

	for file: FileStatistics in get_category(category):
		if file is ResourceStatistics:
			@warning_ignore("unsafe_property_access")
			total += file.scene_connection_count

	return total


func _is_path_ignored(
		path: String,
		ignored_paths: PackedStringArray,
		included_paths: PackedStringArray,
) -> bool:
	for included_path: String in included_paths:
		if path.match(included_path):
			return false

	for ignored_path: String in ignored_paths:
		if path.match(ignored_path):
			return true

	return false


func _load_directory(
		root_path: String = "res://",
		ignored_paths: PackedStringArray = [],
		included_paths: PackedStringArray = [],
) -> void:
	var root: DirAccess = DirAccess.open(root_path)
	if not root:
		return

	root.include_hidden = false
	root.include_navigational = false

	var directory_names: PackedStringArray = root.get_directories()

	for directory_name: String in directory_names:
		var directory_path: String = root_path.path_join(directory_name)

		_load_directory(directory_path, ignored_paths, included_paths)

	var file_names: PackedStringArray = root.get_files()

	for file_name: String in file_names:
		var file_path: String = root_path.path_join(file_name)

		if _is_path_ignored(file_path, ignored_paths, included_paths):
			continue

		var file_statistics: FileStatistics = _get_file_statistics(file_path)

		if not file_statistics:
			continue

		if file_statistics.file_is_scene:
			scenes.append(file_statistics)
		elif file_statistics.file_is_script:
			scripts.append(file_statistics)
		elif file_statistics.file_is_resource:
			resources.append(file_statistics)
		else:
			misc.append(file_statistics)


func _get_file_statistics(file_path: String) -> FileStatistics:
	var file_stats: FileStatistics

	match file_path.get_extension().to_lower():
		"cs":
			file_stats = CSharpStatistics.new(file_path)
		"ini", "cfg":
			file_stats = ConfigFileStatistics.new(file_path)
		"gd":
			file_stats = GDScriptStatistics.new(file_path)
		"md":
			file_stats = MarkdownStatistics.new(file_path)
		"json":
			file_stats = JsonStatistics.new(file_path)
		"yml", "yaml":
			file_stats = YamlStatistics.new(file_path)
		"tscn", "tres":
			file_stats = ResourceStatistics.new(file_path)
		_:
			file_stats = ResourceStatistics.new(file_path, true)

	if file_stats.loading_failed:
		return null

	return file_stats
