class_name MarkdownStatistics
extends FileStatistics

func _init(path: String, skip_line_count: bool = false) -> void:
	super(path, skip_line_count)

	file_icon = "uid://bjgn0w383fm4d"
	file_color = Color.GHOST_WHITE
	file_type = "Markdown"
