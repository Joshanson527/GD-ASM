class_name JsonStatistics
extends FileStatistics

func _init(path: String, skip_line_count: bool = false) -> void:
	super(path, skip_line_count)

	file_icon = "uid://ck8etdf6mpwp"
	file_color = Color.GOLD
	file_type = "JSON"
