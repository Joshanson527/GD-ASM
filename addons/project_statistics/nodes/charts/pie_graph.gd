@tool
class_name PieGraph
extends HBoxContainer

const CIRCLE_ICON: Texture2D = preload("uid://dnmnnqeaagyto")

@onready var chart: PieChart = $MarginContainer/PieChart
@onready var tree: Tree = $Tree


func set_series(series: Array[ChartData], sort: bool = true) -> void:
	chart.set_series(series, sort)
	tree.clear()

	var root: TreeItem = tree.create_item()

	for data: ChartData in chart.series:
		var item: TreeItem = tree.create_item(root)
		item.set_icon(0, CIRCLE_ICON)
		item.set_icon_modulate(0, data.color)
		item.set_icon_max_width(0, 8)
		item.set_text(0, data.name)
		item.set_text(1, "%05.2f" % (data.value / chart.total * 100))
		item.set_suffix(1, "%")
		item.set_tooltip_text(1, data.tooltip)
