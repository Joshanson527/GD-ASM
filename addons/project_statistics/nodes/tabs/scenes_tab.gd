@tool
class_name ScenesTab
extends BaseTab

var total_scenes: TreeItem
var total_nodes: TreeItem
var total_connections: TreeItem
var total_size: TreeItem

@onready var summary: Tree = $Summary
@onready var tree_view: TreeView = $TreeView


func _ready() -> void:
	var root: TreeItem = summary.create_item()

	total_scenes = create_tree_item(root, "Total scenes")
	total_nodes = create_tree_item(root, "Total nodes")
	total_connections = create_tree_item(root, "Total connections")
	total_size = create_tree_item(root, "Total size")

	tree_view.column_names = [
		TreeViewColumn.new("Scene", TreeViewColumn.Type.FILE_NAME),
		TreeViewColumn.new("Base node", TreeViewColumn.Type.SCENE_BASE_NODE_TYPE),
		TreeViewColumn.new("Node count", TreeViewColumn.Type.SCENE_NODE_COUNT),
		TreeViewColumn.new("Connection count", TreeViewColumn.Type.SCENE_NODE_CONNECTION_COUNT),
		TreeViewColumn.new("Local to scene", TreeViewColumn.Type.RESOURCE_LOCAL_TO_SCENE),
		TreeViewColumn.new("Size", TreeViewColumn.Type.FILE_SIZE),
	]

	tree_view.set_column_expand_ratio(0, 2)
	tree_view.set_column_expand_ratio(1, 2)
	tree_view.set_column_expand_ratio(2, 1)
	tree_view.set_column_expand_ratio(3, 1)
	tree_view.set_column_expand_ratio(4, 1)
	tree_view.set_column_expand_ratio(5, 1)


func update(new_stats: ProjectStatistics) -> void:
	total_scenes.set_text(1, str(new_stats.scenes.size()))
	total_nodes.set_text(1, str(new_stats.get_total_scene_node_count(ProjectStatistics.Category.SCENE)))
	total_connections.set_text(1, str(new_stats.get_total_scene_connection_count(ProjectStatistics.Category.SCENE)))
	total_size.set_text(1, String.humanize_size(new_stats.get_total_size(ProjectStatistics.Category.SCENE)))

	tree_view.row_files = new_stats.scenes.duplicate()
