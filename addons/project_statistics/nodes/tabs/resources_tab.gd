@tool
class_name ResourcesTab
extends BaseTab

var total_resources: TreeItem
var total_size: TreeItem

@onready var summary: Tree = $HSplitContainer/Summary
@onready var pie_graph: PieGraph = $HSplitContainer/PieGraph
@onready var tree_view: TreeView = $TreeView


func _ready() -> void:
	var root: TreeItem = summary.create_item()

	total_resources = create_tree_item(root, "Total resources")
	total_size = create_tree_item(root, "Total size")

	tree_view.column_names = [
		TreeViewColumn.new("File name", TreeViewColumn.Type.FILE_NAME),
		TreeViewColumn.new("Type", TreeViewColumn.Type.FILE_TYPE),
		TreeViewColumn.new("Local to scene", TreeViewColumn.Type.RESOURCE_LOCAL_TO_SCENE),
		TreeViewColumn.new("Size", TreeViewColumn.Type.FILE_SIZE),
	]

	tree_view.set_column_expand_ratio(0, 2)
	tree_view.set_column_expand_ratio(1, 2)
	tree_view.set_column_expand_ratio(2, 1)
	tree_view.set_column_expand_ratio(3, 1)


func update(new_stats: ProjectStatistics) -> void:
	total_resources.set_text(1, str(new_stats.resources.size()))
	total_size.set_text(1, String.humanize_size(new_stats.get_total_size(ProjectStatistics.Category.RESOURCE)))

	tree_view.row_files = new_stats.resources.duplicate()

	var graph_data: Array[ChartData]

	var size_dict: Dictionary[String, int] = new_stats.get_total_size_by_file_type(ProjectStatistics.Category.RESOURCE)
	var color_dict: Dictionary[String, Color] = new_stats.get_color_by_file_type(ProjectStatistics.Category.RESOURCE)

	for type: String in size_dict.keys():
		graph_data.append(
			ChartData.new(
				type,
				size_dict[type],
				color_dict[type],
				String.humanize_size(size_dict[type]),
			),
		)

	pie_graph.set_series(graph_data)
