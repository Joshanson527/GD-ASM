@tool
class_name PieChart
extends Control

var series: Array[ChartData]
var total: float

@export var outline_width: float = 1.2
## this variable is in points per PI
@export var points_density: float = 16


func _draw() -> void:
	var radius: float = min(size.x, size.y) / 2
	var center: Vector2 = size / 2.0
	var start_angle: float = 0.0

	for data: ChartData in series:
		var percent: float = data.value / total
		var end_angle: float = start_angle + percent * 2 * PI

		_draw_filled_arc(
			center,
			radius,
			start_angle,
			end_angle,
			data.color,
		)
		start_angle = end_angle

	if not get_theme_constant("dark_theme", "Editor"):
		draw_arc(
			center,
			radius - outline_width / 2,
			0.0,
			2 * PI,
			int(points_density * 2),
			Color.LIGHT_SLATE_GRAY,
			outline_width,
			true,
		)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			queue_redraw()


func clear() -> void:
	series.clear()
	_update_total()
	queue_redraw()


func add_data(data: ChartData, sort: bool) -> void:
	series.append(data)
	_update_total()

	if sort:
		series.sort_custom(
			func(a: ChartData, b: ChartData) -> bool:
				return a.value < b.value
		)

	queue_redraw()


func set_series(new_series: Array[ChartData], sort: bool) -> void:
	series = new_series
	_update_total()

	if sort:
		series.sort_custom(
			func(a: ChartData, b: ChartData) -> bool:
				return a.value < b.value
		)

	queue_redraw()


func remove_data(data_name: String) -> void:
	for index: int in range(series.size()):
		if series[index].name == data_name:
			series.remove_at(index)

	_update_total()
	queue_redraw()


func _update_total() -> void:
	total = 0.0

	for data: ChartData in series:
		total += data.value


func _draw_filled_arc(
		center: Vector2,
		radius: float,
		start_angle: float,
		end_angle: float,
		color: Color,
) -> void:
	var points: PackedVector2Array = []
	points.push_back(center)
	points.push_back(center + Vector2(sin(start_angle), -cos(start_angle)) * radius) # Start point

	var arc_points_count: int = int((end_angle - start_angle) * points_density)
	var step: float = (end_angle - start_angle) / (arc_points_count + 1)

	for index: int in range(arc_points_count):
		var point_angle: float = start_angle + index * step
		points.push_back(center + Vector2(sin(point_angle), -cos(point_angle)) * radius)

	points.push_back(center + Vector2(sin(end_angle), -cos(end_angle)) * radius) # End point
	draw_polygon(points, [color])
