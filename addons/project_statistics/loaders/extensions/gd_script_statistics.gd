class_name GDScriptStatistics
extends FileStatistics

func _init(path: String, skip_line_count: bool = false) -> void:
	super(path, skip_line_count)

	file_icon = "GDScript"
	file_color = Color.STEEL_BLUE
	file_type = "GDScript"
	file_is_script = true


func get_type_of_line(line: String) -> LineType:
	line = line.strip_edges()

	if line.is_empty():
		return LineType.BLANK

	if line.begins_with("#"):
		return LineType.SINGLE_LINE_COMMENT

	if line == "\"\"\"":
		return LineType.COMMENT_START_OR_END

	if line.begins_with("\"\"\"") and line.ends_with("\"\"\"") and line.count("\"") >= 6:
		return LineType.SINGLE_LINE_COMMENT

	if line.begins_with("\"\"\""):
		return LineType.COMMENT_START

	if line.ends_with("\"\"\""):
		return LineType.COMMENT_END

	return LineType.CODE
