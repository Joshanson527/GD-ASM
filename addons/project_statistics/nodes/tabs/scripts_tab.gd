@tool
class_name ScriptsTab
extends BaseTab

var total_scripts: TreeItem
var used_languages: TreeItem
var total_lines: TreeItem
var total_code_lines: TreeItem
var total_comments_lines: TreeItem
var total_blank_lines: TreeItem
var total_size: TreeItem

@onready var summary: Tree = $HSplitContainer/Summary
@onready var pie_graph: PieGraph = $HSplitContainer/PieGraph
@onready var tree_view: TreeView = $TreeView


func _ready() -> void:
	var root: TreeItem = summary.create_item()

	total_scripts = create_tree_item(root, "Total scripts")
	used_languages = create_tree_item(root, "Used languages")
	total_lines = create_tree_item(root, "Total lines")
	total_code_lines = create_tree_item(total_lines, "Code lines")
	total_comments_lines = create_tree_item(total_lines, "Comments lines")
	total_blank_lines = create_tree_item(total_lines, "Blank lines")
	total_size = create_tree_item(root, "Total size")

	total_lines.collapsed = true

	tree_view.column_names = [
		TreeViewColumn.new("File name", TreeViewColumn.Type.FILE_NAME),
		TreeViewColumn.new("Language", TreeViewColumn.Type.FILE_TYPE),
		TreeViewColumn.new("Total lines", TreeViewColumn.Type.FILE_TOTAL_LINES),
		TreeViewColumn.new("Code lines", TreeViewColumn.Type.FILE_CODE_LINES),
		TreeViewColumn.new("Comment lines", TreeViewColumn.Type.FILE_COMENT_LINES),
		TreeViewColumn.new("Blank lines", TreeViewColumn.Type.FILE_BLANK_LINES),
		TreeViewColumn.new("Size", TreeViewColumn.Type.FILE_SIZE),
	]

	tree_view.set_column_expand_ratio(0, 2)
	tree_view.set_column_expand_ratio(1, 2)
	tree_view.set_column_expand_ratio(2, 1)
	tree_view.set_column_expand_ratio(3, 1)
	tree_view.set_column_expand_ratio(4, 1)
	tree_view.set_column_expand_ratio(5, 1)
	tree_view.set_column_expand_ratio(6, 1)


func update(new_stats: ProjectStatistics) -> void:
	total_scripts.set_text(1, str(new_stats.scripts.size()))
	used_languages.set_text(1, ", ".join(new_stats.get_file_types(ProjectStatistics.Category.SCRIPT)))
	total_lines.set_text(1, str(new_stats.get_total_lines(ProjectStatistics.Category.SCRIPT)))
	total_code_lines.set_text(1, str(new_stats.get_total_code_lines(ProjectStatistics.Category.SCRIPT)))
	total_comments_lines.set_text(1, str(new_stats.get_total_comment_lines(ProjectStatistics.Category.SCRIPT)))
	total_blank_lines.set_text(1, str(new_stats.get_total_blank_lines(ProjectStatistics.Category.SCRIPT)))
	total_size.set_text(1, String.humanize_size(new_stats.get_total_size(ProjectStatistics.Category.SCRIPT)))

	tree_view.row_files = new_stats.scripts.duplicate()

	var graph_data: Array[ChartData]

	var lenght_dict: Dictionary[String, int] = new_stats.get_total_lines_by_file_type(ProjectStatistics.Category.SCRIPT)
	var color_dict: Dictionary[String, Color] = new_stats.get_color_by_file_type(ProjectStatistics.Category.SCRIPT)

	for language: String in lenght_dict.keys():
		graph_data.append(
			ChartData.new(
				language,
				lenght_dict[language],
				color_dict[language],
				"%s lines" % lenght_dict[language],
			),
		)

	pie_graph.set_series(graph_data)
