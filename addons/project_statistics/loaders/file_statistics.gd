class_name FileStatistics
extends RefCounted

enum LineType {
	CODE,
	BLANK,
	SINGLE_LINE_COMMENT,
	COMMENT_START,
	COMMENT_START_OR_END,
	COMMENT_END,
}

var file_path: String = ""
var file_size: int = 0
var file_total_lines: int = 0
var file_code_lines: int = 0
var file_comment_lines: int = 0
var file_blank_lines: int = 0

var file_name: String:
	get():
		return file_path.get_file()
var file_extension: String:
	get():
		return file_path.get_extension()

# Following variables are supposed to be initialized by child class
var file_icon: String = ""
var file_color: Color = Color.TRANSPARENT
var file_is_script: bool = false
var file_is_scene: bool = false
var file_is_resource: bool = false
var file_type: String = ""

var loading_failed: bool = false


func _init(path: String, skip_line_count: bool = false) -> void:
	file_path = path

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)

	if not file:
		loading_failed = true
		return

	file_size = file.get_length()

	if skip_line_count:
		return

	var in_multi_line_comment: bool = false

	while not file.eof_reached():
		var line: String = file.get_line()
		var type_of_line: LineType = get_type_of_line(line)
		file_total_lines += 1

		if type_of_line == LineType.BLANK:
			file_blank_lines += 1
			continue

		if in_multi_line_comment:
			file_comment_lines += 1
			if type_of_line == LineType.COMMENT_START_OR_END or type_of_line == LineType.COMMENT_END:
				in_multi_line_comment = false
			continue
		else:
			if type_of_line == LineType.COMMENT_START_OR_END or type_of_line == LineType.COMMENT_START:
				file_comment_lines += 1
				in_multi_line_comment = true
				continue

		if type_of_line == LineType.SINGLE_LINE_COMMENT:
			file_comment_lines += 1
			continue

		if type_of_line == LineType.CODE:
			file_code_lines += 1
			continue

		push_error("Unknown return value.")

	file.close()


func get_type_of_line(line: String) -> LineType:
	if line.strip_edges().is_empty():
		return LineType.BLANK

	return LineType.CODE
