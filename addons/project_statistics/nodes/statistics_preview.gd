@tool
class_name StatisticsPreview
extends VBoxContainer

const IGNORE_PROPERTY: String = "statistics/ignore"
const INCLUDE_PROPERTY: String = "statistics/include"
const LOAD_ON_STARTUP_PROPERTY: String = "statistics/load_on_startup"

@export var tabs: Array[BaseTab]

var default_ignore: PackedStringArray = PackedStringArray(
	[
		"res://.import/*",
		"res://.github/*",
		"res://addons/*",
		"*.import",
		"*.uid",
	],
)


func _ready() -> void:
	_setup()

	if ProjectSettings.get_setting(LOAD_ON_STARTUP_PROPERTY):
		_on_refresh_pressed()


func _on_refresh_pressed() -> void:
	var ignore: Variant = ProjectSettings.get_setting(IGNORE_PROPERTY)
	var include: Variant = ProjectSettings.get_setting(INCLUDE_PROPERTY)

	# HACK: Sometimes it fails to load project settings data and null is returned,
	# this workaround works to prevent cast error.
	if ignore == null or include == null:
		return

	@warning_ignore("unsafe_cast")
	var stats: ProjectStatistics = ProjectStatistics.new(
		ignore as PackedStringArray,
		include as PackedStringArray,
	)

	for tab: BaseTab in tabs:
		tab.update(stats)


func _setup() -> void:
	if not ProjectSettings.has_setting(LOAD_ON_STARTUP_PROPERTY):
		ProjectSettings.set_setting(LOAD_ON_STARTUP_PROPERTY, true)
		ProjectSettings.add_property_info(
			{
				"name"= LOAD_ON_STARTUP_PROPERTY,
				"type"= TYPE_BOOL,
			},
		)

	if not ProjectSettings.has_setting(IGNORE_PROPERTY):
		ProjectSettings.set_setting(IGNORE_PROPERTY, default_ignore)
		ProjectSettings.add_property_info(
			{
				"name"= IGNORE_PROPERTY,
				"type"= TYPE_PACKED_STRING_ARRAY,
			},
		)

	if not ProjectSettings.has_setting(INCLUDE_PROPERTY):
		ProjectSettings.set_setting(INCLUDE_PROPERTY, PackedStringArray())
		ProjectSettings.add_property_info(
			{
				"name"= INCLUDE_PROPERTY,
				"type"= TYPE_PACKED_STRING_ARRAY,
			},
		)

	ProjectSettings.set_initial_value(LOAD_ON_STARTUP_PROPERTY, true)
	ProjectSettings.set_initial_value(IGNORE_PROPERTY, default_ignore)
	ProjectSettings.set_initial_value(INCLUDE_PROPERTY, PackedStringArray())
