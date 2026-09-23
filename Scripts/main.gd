extends Control

@export var language: AssemblyLanguage

@onready var code_edit: CodeEdit = $VSplitContainer/TabContainer/CodeEdit
@onready var split: VSplitContainer = $VSplitContainer
@onready var console: RichTextLabel = $VSplitContainer/HSplitContainer/ConsoleContainer/VBoxContainer/MarginContainer/Console
@onready var parse_timer: Timer = $ParseTimer
@onready var error_tooltip: PanelContainer = $ErrorTooltip

var labels: Array[String] = []
var errors: Dictionary[int, String] = {}
var mnemonics: Array[String] = []
var path: String = ""

func _ready() -> void:
	var highlighter = CodeHighlighter.new()
	highlighter.number_color = Color(0.655, 1.0, 0.627)
	highlighter.symbol_color = Color(0.655, 1.0, 0.627)
	for instruction in language.instructions:
		mnemonics.append(instruction.mnemonic)
		highlighter.add_keyword_color(instruction.mnemonic, instruction.color)
	highlighter.add_color_region(".", " ", Color(0.0, 0.647, 0.422, 1.0), true)
	highlighter.add_color_region(";", "", Color(0.0, 0.543, 0.002, 1.0))
	code_edit.syntax_highlighter = highlighter
	parse_code()
	console.clear()
	console_log("hello this is a test")
	console_log("green for an amazing reason", 2)



func _on_code_edit_text_changed() -> void:
	parse_timer.start()

func _on_parse_timer_timeout() -> void:
	parse_code()

func _on_code_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var line := code_edit.get_line_column_at_pos(event.position, false, false)
		if line.y in errors.keys():
			error_tooltip.size = Vector2.ZERO
			error_tooltip.get_child(0).get_child(0).text = errors[line.y]
			var line_rect := code_edit.get_rect_at_line_column(line.y, line.x)
			error_tooltip.position = Vector2(code_edit.global_position.x + 40, code_edit.global_position.y + line_rect.position.y + line_rect.size.y)
			error_tooltip.show()
		else:
			error_tooltip.hide()

func _on_console_meta_clicked(meta: Variant) -> void:
	var line: int = str(meta).to_int()
	code_edit.grab_focus()
	code_edit.set_caret_line(line)
	code_edit.set_caret_column(code_edit.get_line(line).length())




func parse_code() -> void:
	for line in range(code_edit.get_line_count()):
		code_edit.set_line_background_color(line, Color(0, 0, 0, 0))
	
	errors = {}
	labels = []
	for line_number in range(code_edit.get_line_count()):
		var line := code_edit.get_line(line_number)
		if not "." in line:
			continue
		line = line.strip_edges()
		if ";" in line:
			line = line.split(";")[0].strip_edges()
		var parts := line.split(" ", false)
		if parts[0].begins_with(".") and len(parts) == 1:
			if parts[0] in labels:
				errors.set(line_number, "Duplicate label " + parts[0])
				continue
			labels.append(parts[0])
	
	for line_number in range(code_edit.get_line_count()):
		var line := code_edit.get_line(line_number)
		
		if line.strip_edges().is_empty():
			continue
		
		var error := parse_line(line)
		if error != "":
			errors.set(line_number, error)
	
	for error in errors.keys():
		code_edit.set_line_background_color(error, Color(0.831, 0.122, 0.118, 0.224))

func parse_line(line: String) -> String:
	line = line.strip_edges()
	if ";" in line:
		line = line.split(";")[0].strip_edges()
	if line.is_empty():
		return ""
	
	var parts := line.split(" ", false)
	if parts[0].begins_with("."):
		if len(parts) == 1:
			return ""
		else:
			return "Labels cannot have arguments"
	
	if parts[0] in mnemonics:
		var instruction := language.instructions[mnemonics.find(parts[0])]
		parts.remove_at(0)
		match instruction.encoding_type:
			AssemblyInstruction.EncodingType.STANDALONE:
				if len(parts) > 0:
					return "Instruction " + instruction.mnemonic + " takes 0 arguments but " + str(len(parts)) + (" was given" if len(parts) == 1 else " were given")
			AssemblyInstruction.EncodingType.OPERAND:
				if len(parts) != 1:
					return "Instruction " + instruction.mnemonic + " takes 1 argument but " + str(len(parts)) + (" was given" if len(parts) == 1 else " were given")
				var num := parse_num(parts[0])
				if num < 0:
					match num:
						-1:
							return "Hex constructor is empty"
						-2:
							return "Binary constructor is empty"
						-3:
							return "Invalid hex number: " + parts[0]
						-4:
							return "Invalid binary number: " + parts[0]
						-5:
							return "Argument is not a number"
						-6:
							return "Argument must be a positive number"
				elif num > 15:
					return "Argument must be between 0 and 15 (4 bits)"
			AssemblyInstruction.EncodingType.SELECT_BIT:
				if len(parts) > 0:
					return "Instruction " + instruction.mnemonic + " takes 0 arguments but " + str(len(parts)) + (" was given" if len(parts) == 1 else " were given")
			AssemblyInstruction.EncodingType.SELECT_BIT_OPERAND:
				if len(parts) != 1:
					return "Instruction " + instruction.mnemonic + " takes 1 argument but " + str(len(parts)) + (" was given" if len(parts) == 1 else " were given")
				var num := parse_num(parts[0])
				if num < 0:
					match num:
						-1:
							return "Hex constructor is empty"
						-2:
							return "Binary constructor is empty"
						-3:
							return "Invalid hex number: " + parts[0]
						-4:
							return "Invalid binary number: " + parts[0]
						-5:
							return "Argument is not a number"
						-6:
							return "Argument must be a positive number"
				elif num > 7:
					return "Argument must be between 0 and 7 (3 bits)"
			AssemblyInstruction.EncodingType.RAM_ADDRESS:
				if len(parts) != 1:
					return "Instruction " + instruction.mnemonic + " takes 1 argument but " + str(len(parts)) + (" was given" if len(parts) == 1 else " were given")
				var num := parse_num(parts[0])
				if num < 0:
					match num:
						-1:
							return "Hex constructor is empty"
						-2:
							return "Binary constructor is empty"
						-3:
							return "Invalid hex number: " + parts[0]
						-4:
							return "Invalid binary number: " + parts[0]
						-5:
							return "Argument is not a number"
						-6:
							return "Argument must be a positive number"
				elif num > 4095:
					return "Argument must be between 0 and 2047 (11 bits)"
			AssemblyInstruction.EncodingType.PROG_ADDRESS:
				if len(parts) != 1:
					return "Instruction " + instruction.mnemonic + " takes 1 argument but " + str(len(parts)) + (" was given" if len(parts) == 1 else " were given")
				if not parts[0] in labels:
					if parts[0].begins_with("."):
						return "Could not find label definition"
					return "Instruction requres a label to jump to"
	else:
		return "Invalid mnemonic: " + parts[0]
	
	return ""

func compile() -> int:
	console.clear()
	console_log("Starting compiler...")
	
	var lines: Array = code_edit.text.split("\n")
	var cleaned_lines: Array[String] = []
	for line in lines:
		line = line.strip_edges()
		if ";" in line:
			line = line.split(";")[0].strip_edges()
		if not line.is_empty():
			cleaned_lines.append(line)
	lines = cleaned_lines
	
	console_log("Loaded " + str(lines.size()) + " source lines")
	console.newline()
	console_log("Parsing code...", 1)
	parse_code()
	if not errors.is_empty():
		console_log("Parsing generated " + str(errors.size()) + " errors:", 4)
		var keys := errors.keys()
		keys.sort()
		for key in keys:
			console_log("Line " + str(key + 1) + ": " + errors[key], 4, false, key, "	")
		return -1
	console_log("Parsing completed, no errors", 2)
	console.newline()
	
	console_log("Discovering labels...", 1)
	var label_addresses: Dictionary[String, int] = {}
	var collapsed_lines: Array[String] = []
	var current_address: int = 0
	for line: String in lines:
		if line.begins_with("."):
			label_addresses.set(line, current_address)
		else:
			collapsed_lines.append(line)
			var parts := line.split(" ", false)
			var instruction: AssemblyInstruction = language.instructions.filter(func(inst): return inst.mnemonic == parts[0])[0]
			match instruction.encoding_type:
				AssemblyInstruction.EncodingType.RAM_ADDRESS, AssemblyInstruction.EncodingType.PROG_ADDRESS:
					current_address += 2
				_:
					current_address += 1
	lines = collapsed_lines
	for label in label_addresses.keys():
		if not lines.any(func(line): return line.contains(label)):
			console_log("Label " + label + " is defined but not used", 3)
	console_log("Found " + str(label_addresses.size()) + " labels")
	console_log("Labels collapsed", 2)
	console.newline()
	
	console_log("Compiling instructions...", 1)
	var program: PackedByteArray = []
	for line_index in range(lines.size()):
		var line: String = lines[line_index]
		var parts := line.split(" ")
		var instruction: AssemblyInstruction = language.instructions.filter(func(inst): return inst.mnemonic == parts[0])[0]
		match instruction.encoding_type:
			AssemblyInstruction.EncodingType.STANDALONE:
				program.append(instruction.opcode << 4)
			AssemblyInstruction.EncodingType.OPERAND:
				program.append(instruction.opcode << 4 | (parse_num(parts[1]) & 0b1111)) # mask to ensure operand is 4 bits
			AssemblyInstruction.EncodingType.SELECT_BIT:
				program.append(instruction.opcode << 4 | instruction.selection_bit << 3) # correctly place selection bit in bit 3
			AssemblyInstruction.EncodingType.SELECT_BIT_OPERAND:
				program.append(instruction.opcode << 4 | instruction.selection_bit << 3 | (parse_num(parts[1]) & 0b0111)) # mask to ensure operand is 3 bits
			AssemblyInstruction.EncodingType.RAM_ADDRESS:
				var address := parse_num(parts[1])
				program.append(instruction.opcode << 4 | (address & 0b1111)) # mask lower 4 bits of address
				program.append((address >> 4) & 0b01111111) # shift out lower 4 bits and mask upper 7
			AssemblyInstruction.EncodingType.PROG_ADDRESS:
				var address := label_addresses[parts[1]]
				program.append(instruction.opcode << 4 | (address & 0b1111)) # mask lower 4 bits of address
				program.append((address >> 4) & 0b11111111) # shift out lower 4 bits and mask upper 8
	var prog_len: int = program.size()
	console_log("Output program size: " + str(prog_len) + " bytes")
	if prog_len > 4096:
		console_log("Output program is too large", 4)
		console_log("Program takes up " + str(prog_len - 4096) + " too many bytes")
		return -1
	console_log("Memory usage: " + str((prog_len / 4096.0) * 100).pad_decimals(2) + "%, free memory: " + str(4096 - prog_len) + " bytes")
	@warning_ignore("integer_division")
	if prog_len / 4096 > 0.9:
		console_log("Program is reaching memory limit", 3)
	console_log("Program compiled", 2)
	console.newline()
	
	console_log("Saving output...", 1)
	program.resize(4096)
	if program.size() != 4096:
		console_log("Failed to resize program array")
		return -1
	if not path:
		console_log("File not saved, no dir selected", 4)
		return -1
	if prog_len == 0:
		console.log("No lower hex file needed")
	else:
		var lower: String = program.slice(0, 2048).hex_encode()
		var file_lower := FileAccess.open(path.get_basename() + "-lower.hex", FileAccess.WRITE)
		if file_lower:
			file_lower.store_string(hex_format(lower))
			file_lower.close()
			console_log("Saved lower hex data as " + path.get_basename() + "-lower.hex", 2)
	if prog_len <= 2048:
		console_log("No upper hex file needed")
	else:
		var upper: String = program.slice(2048, 4096).hex_encode()
		var file_upper := FileAccess.open(path.get_basename() + "-upper.hex", FileAccess.WRITE)
		if file_upper:
			file_upper.store_string(hex_format(upper))
			file_upper.close()
			console_log("Saved upper hex data as " + path.get_basename() + "-upper.hex", 2)
	console.newline()
	console_log("Compiled successfully!", 2)
	return 0



func console_log(message: String, level: int = 0, use_prefix: bool = true, line_link: int = -1, indent: String = "") -> void:
	var color: Color
	var prefix: String
	match level:
		1:
			color = Color(0.027, 0.498, 0.973)
			prefix = "[STEP] "
		2:
			color = Color(0.305, 0.817, 0.284)
			prefix = "[ OK ] "
		3:
			color = Color(0.851, 0.757, 0.145)
			prefix = "[WARN] "
		4:
			color = Color(1.0, 0.287, 0.225, 1.0)
			prefix = "[ERROR] "
		_:
			color = Color(0.878, 0.878, 0.878)
			prefix = "[INFO] "
	if not use_prefix:
		prefix = ""
	if line_link == -1:
		console.append_text(indent + "[color=#" + color.to_html(false) + "]" + prefix +message + "[/color]\n")
	else:
		console.append_text(indent + "[url=" + str(line_link) + "][color=#" + color.to_html(false) + "]" + prefix + message + "[/color][/url]\n")
	print("Console: " + prefix + " " + message)

func hex_format(hex: String) -> String:
	var output: String = ""
	for i in range(0, hex.length(), 2):
		output += hex[i] + hex[i + 1] + " "
		if i % 32 == 30:
			output += "\n"
	return output

func parse_num(value: String) -> int:
	value = value.strip_edges().to_lower()
	if value.is_valid_int():
		if value.to_int() >= 0:
			return value.to_int()
		else:
			return -6
	
	if value.begins_with("0x"):
		var hex_value := value.substr(2)
		if hex_value.is_empty():
			return -1
		for c in hex_value:
			if not c in "0123456789abcdef":
				return -3
		return hex_value.hex_to_int()
	
	if value.begins_with("0b"):
		var bin_value := value.substr(2)
		if bin_value.is_empty():
			return -2
		for c in bin_value:
			if not c in "01":
				return -4
		return bin_value.bin_to_int()
	
	return -5
