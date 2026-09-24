@tool
class_name OverviewTab
extends BaseTab

var total_scenes: TreeItem
var total_resources: TreeItem
var total_scripts: TreeItem
var other_files: TreeItem

@onready var tree: Tree = $Panel/Tree
@onready var pie_graph: PieGraph = $PieGraph


func init_sub_tree(parent: TreeItem, data: Dictionary[String, int]) -> void:
	for child: TreeItem in parent.get_children():
		if child.get_child_count() != 0:
			push_warning("Item has children which may lead to memory leak")

		parent.remove_child(child)
		child.free()

	for data_key: String in data.keys():
		var new_child: TreeItem = parent.create_child()
		new_child.set_icon_max_width(0, 16)
		new_child.set_icon(0, _get_icon(data_key))
		new_child.set_text(0, data_key)
		new_child.set_text(1, str(data[data_key]))


func _ready() -> void:
	var root: TreeItem = tree.create_item()

	total_scenes = create_tree_item(root, "Total scenes")
	total_resources = create_tree_item(root, "Total resources")
	total_scripts = create_tree_item(root, "Total scripts")
	other_files = create_tree_item(root, "Other files")

	total_scenes.set_icon(0, get_theme_icon("PackedScene", "EditorIcons"))
	total_resources.set_icon(0, get_theme_icon("Object", "EditorIcons"))
	total_scripts.set_icon(0, get_theme_icon("Script", "EditorIcons"))
	other_files.set_icon(0, get_theme_icon("File", "EditorIcons"))

	total_resources.collapsed = true
	total_scripts.collapsed = true
	other_files.collapsed = true


func update(new_stats: ProjectStatistics) -> void:
	total_scenes.set_text(1, str(new_stats.scenes.size()))
	total_resources.set_text(1, str(new_stats.resources.size()))
	total_scripts.set_text(1, str(new_stats.scripts.size()))
	other_files.set_text(1, str(new_stats.misc.size()))

	init_sub_tree(total_resources, new_stats.get_file_count_by_file_type(ProjectStatistics.Category.RESOURCE))
	init_sub_tree(total_scripts, new_stats.get_file_count_by_file_type(ProjectStatistics.Category.SCRIPT))
	init_sub_tree(other_files, new_stats.get_file_count_by_file_type(ProjectStatistics.Category.MISC))

	var graph_data: Array[ChartData] = [
		ChartData.new("Scenes", new_stats.scenes.size(), Color.INDIAN_RED),
		ChartData.new("Resources", new_stats.resources.size(), Color.ORANGE),
		ChartData.new("Scripts", new_stats.scripts.size(), Color.LIGHT_SEA_GREEN),
		ChartData.new("Other", new_stats.misc.size(), Color.LIGHT_GRAY),
	]

	pie_graph.set_series(graph_data, false)


func _get_icon(icon_name: String) -> Texture2D:
	# HACK: This function is a big workaround

	if EditorInterface.get_base_control().has_theme_icon(icon_name, "EditorIcons"):
		return EditorInterface.get_base_control().get_theme_icon(icon_name, "EditorIcons")

	var icon_path: String = ""

	match icon_name:
		"YAMl":
			icon_path = "uid://b3b4dcp7nls3r"
		"JSON":
			icon_path = "uid://ck8etdf6mpwp"
		"Markdown":
			icon_path = "uid://bjgn0w383fm4d"
		"Config File":
			pass

	if ResourceLoader.exists(icon_path):
		return ResourceLoader.load(icon_path)

	return null
