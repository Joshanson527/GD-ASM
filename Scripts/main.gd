extends Control

@onready var menu_handler: Node = $MenuHandler
@onready var split: VSplitContainer = $VSplitContainer
@onready var error_tooltip: PanelContainer = $ErrorTooltip

@export var language: AssemblyLanguage
var path: String = ""


func _ready() -> void:
	Console.console = get_node("VSplitContainer/HSplitContainer/ConsoleContainer/VBoxContainer/MarginContainer/Console")
	$Version.text = "GD-ASM v" + str(ProjectSettings.get_setting("application/config/version", "0.1")) + " by Joshanson527"
	var highlighter = CodeHighlighter.new()
	highlighter.number_color = Color(0.694, 0.958, 0.427, 1.0)
	highlighter.symbol_color = Color(0.694, 0.958, 0.427, 1.0)
	for instruction in language.instructions:
		Compiler.mnemonics.append(instruction.mnemonic)
		highlighter.add_keyword_color(instruction.mnemonic, instruction.color)
	highlighter.add_color_region(".", "", Color(0.202, 0.563, 0.482, 1.0), true)
	highlighter.add_color_region(";", "", Color(0.0, 0.456, 0.001, 1.0))
	menu_handler.highlighter = highlighter
	Console.clear()
	Console.log("hello this is a test")
	Console.ok("green for an amazing reason")

func _on_code_gui_input(event: InputEvent, code_edit: CodeEdit) -> void:
	if event is InputEventMouseMotion:
		var line := code_edit.get_line_column_at_pos(event.position, false, false)
		if line.y in code_edit.errors.keys():
			error_tooltip.size = Vector2.ZERO
			error_tooltip.get_child(0).get_child(0).text = code_edit.errors[line.y]
			var line_rect := code_edit.get_rect_at_line_column(line.y, line.x)
			error_tooltip.position = Vector2(code_edit.global_position.x + 40, code_edit.global_position.y + line_rect.position.y + line_rect.size.y)
			error_tooltip.show()
		else:
			error_tooltip.hide()
