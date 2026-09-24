class_name BaseTab
extends Control

@warning_ignore("unused_parameter")
func update(new_stats: ProjectStatistics) -> void:
	pass


func create_tree_item(parent: TreeItem, first_column: String) -> TreeItem:
	var item: TreeItem = parent.create_child()
	item.set_text(0, first_column)
	return item
