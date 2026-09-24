class_name ChartData
extends RefCounted

var name: String
var value: float
var color: Color
var tooltip: String


func _init(
		new_name: String = "",
		new_value: float = 0.0,
		new_color: Color = Color.TRANSPARENT,
		new_tooltip: String = "",
) -> void:
	name = new_name
	value = new_value
	color = new_color
	tooltip = new_tooltip
