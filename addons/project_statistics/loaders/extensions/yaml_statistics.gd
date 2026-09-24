class_name YamlStatistics
extends FileStatistics

func _init(path: String, skip_line_count: bool = false) -> void:
	super(path, skip_line_count)

	file_icon = "uid://b3b4dcp7nls3r"
	file_color = Color.MEDIUM_PURPLE
	file_type = "YAMl"


func get_type_of_line(line: String) -> LineType:
	line = line.strip_edges()

	if line.is_empty():
		return LineType.BLANK

	if line.begins_with("#"):
		return LineType.SINGLE_LINE_COMMENT

	return LineType.CODE
