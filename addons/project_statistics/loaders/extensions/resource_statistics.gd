class_name ResourceStatistics
extends FileStatistics

var resource_local_to_scene: bool = false
var scene_base_node_type: String = ""
var scene_node_count: int = 0
var scene_connection_count: int = 0


func _init(path: String, skip_line_count: bool = false) -> void:
	super(path, skip_line_count)

	if loading_failed:
		return

	if not ResourceLoader.exists(path):
		loading_failed = true
		return

	var resource: Resource = ResourceLoader.load(path)

	if not resource:
		loading_failed = true
		return

	resource_local_to_scene = resource.resource_local_to_scene

	file_type = resource.get_class()

	if resource is PackedScene:
		file_is_scene = true

		@warning_ignore("unsafe_method_access")
		var state: SceneState = resource.get_state()
		scene_base_node_type = state.get_node_type(0)
		scene_node_count = state.get_node_count()
		scene_connection_count = state.get_connection_count()

	if file_type == "VisualScript":
		file_color = Color.AZURE
	else:
		file_color = Color(hash(file_type)).inverted()
		file_color.a = 1.0

	file_icon = file_type

	file_is_script = ClassDB.is_parent_class(file_type, "Script")
	file_is_resource = true


func get_type_of_line(line: String) -> LineType:
	line = line.strip_edges()

	if line.is_empty():
		return LineType.BLANK

	if line.begins_with(";"):
		return LineType.SINGLE_LINE_COMMENT

	return LineType.CODE
