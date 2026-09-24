@tool
extends EditorPlugin

const STATISTICS_PREVIEW: PackedScene = preload("uid://dope3ks0t5w26")

var dock: EditorDock


func _enter_tree() -> void:
	var preview: StatisticsPreview = STATISTICS_PREVIEW.instantiate()

	dock = EditorDock.new()
	dock.title = "Statistics"
	dock.dock_icon = preload("uid://elxvrkdlcj2u")
	dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	dock.add_child(preview)
	add_dock(dock)


func _exit_tree() -> void:
	remove_dock(dock)
	dock.queue_free()
	dock = null
