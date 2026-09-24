@icon("res://Assets/Icons/hammer.svg")
class_name Compiler
extends Node


static var language: AssemblyLanguage = load("res://language.tres")
static var mnemonics: Array[String] = []


static func parse_code(code_edit: CodeEdit) -> void:
	for line in range(code_edit.get_line_count()):
		code_edit.set_line_background_color(line, Color(0, 0, 0, 0))
	code_edit.errors.clear()
	code_edit.labels.clear()
	for line_number in range(code_edit.get_line_count()):
		var line := code_edit.get_line(line_number)
		if not "." in line:
			continue
		line = line.strip_edges()
		if ";" in line:
			line = line.split(";")[0].strip_edges()
		if line.is_empty():
			continue
		var parts := line.split(" ", false)
		if parts[0].begins_with(".") and len(parts) == 1:
			if parts[0] in code_edit.labels:
				code_edit.errors.set(line_number, "Duplicate label " + parts[0])
				continue
			code_edit.labels.append(parts[0])
			code_edit.label_pos.append(line_number)
	
	for line_number in range(code_edit.get_line_count()):
		var line := code_edit.get_line(line_number)
		
		if line.strip_edges().is_empty():
			continue
		
		var error := parse_line(line, code_edit.labels)
		if error != "":
			code_edit.errors.set(line_number, error)
	
	for error in code_edit.errors.keys():
		code_edit.set_line_background_color(error, Color(0.831, 0.122, 0.118, 0.224))

static func parse_line(line: String, labels: Array[String]) -> String:
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
				var arg_val := validate_argument(parts, instruction.mnemonic, 0, [], [])
				if arg_val != "": return arg_val
			AssemblyInstruction.EncodingType.OPERAND:
				return validate_argument(parts, instruction.mnemonic, 1, ["number"], [15])
			AssemblyInstruction.EncodingType.SELECT_BIT:
				var arg_val := validate_argument(parts, instruction.mnemonic, 0, [], [])
				if arg_val != "": return arg_val
			AssemblyInstruction.EncodingType.SELECT_BIT_OPERAND:
				return validate_argument(parts, instruction.mnemonic, 1, ["number"], [7])
			AssemblyInstruction.EncodingType.RAM_ADDRESS:
				return validate_argument(parts, instruction.mnemonic, 1, ["number"], [2047])
			AssemblyInstruction.EncodingType.PROG_ADDRESS:
				var arg_val := validate_argument(parts, instruction.mnemonic, 1, ["label"], [0])
				if arg_val != "": return arg_val
				if not parts[0] in labels:
					if parts[0].begins_with("."):
						return "Could not find label definition"
					return "Instruction requres a label to jump to"
	else:
		return "Invalid mnemonic: " + parts[0]
	
	return ""

static func compile(code_edit: CodeEdit) -> int:
	Console.clear()
	Console.log("Starting compiler...")
	var save_dir: String = code_edit.path
	Console.log("Compiling " + save_dir.get_file())
	
	var lines: Array = code_edit.text.split("\n")
	var cleaned_lines: Array[String] = []
	for line in lines:
		line = line.strip_edges()
		if ";" in line:
			line = line.split(";")[0].strip_edges()
		if not line.is_empty():
			cleaned_lines.append(line)
	lines = cleaned_lines
	
	Console.log("Loaded " + str(lines.size()) + " source lines")
	Console.newline()
	Console.step("Parsing code...")
	parse_code(code_edit)
	if not code_edit.errors.is_empty():
		Console.error("Parsing generated " + str(code_edit.errors.size()) + " errors:")
		var keys: Array = code_edit.errors.keys()
		keys.sort()
		for key in keys:
			Console.error("Line " + str(key + 1) + ": " + code_edit.errors[key], false, code_edit.path + ":" + str(key), "	")
		return -1
	Console.ok("Parsing completed, no errors")
	Console.newline()
	Console.step("Discovering labels...")
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
			Console.warn("Label " + label + " is defined but not used")
	Console.log("Found " + str(label_addresses.size()) + " labels")
	Console.ok("Labels collapsed")
	Console.newline()
	
	Console.log("Compiling instructions...", 1)
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
	Console.log("Output program size: " + str(prog_len) + " bytes")
	if prog_len > 4096:
		Console.error("Output program is too large")
		Console.error("Program takes up " + str(prog_len - 4096) + " too many bytes", false)
		return -1
	Console.log("Memory usage: " + str((prog_len / 4096.0) * 100).pad_decimals(2) + "%, free memory: " + str(4096 - prog_len) + " bytes")
	if (prog_len / 4096.0) * 100 > 10.0:
		Console.warn("Program is reaching memory limit")
	Console.ok("Program compiled")
	Console.newline()
	
	Console.step("Saving output...")
	program.resize(4096)
	if program.size() != 4096:
		Console.error("Failed to resize program array")
		return -1
	if not save_dir:
		Console.error("File not saved, no dir selected")
		return -1
	if prog_len == 0:
		Console.log("No lower hex file needed")
	else:
		var lower: String = program.slice(0, 2048).hex_encode()
		var file_lower := FileAccess.open(save_dir.get_basename() + "-lower.hex", FileAccess.WRITE)
		if file_lower:
			file_lower.store_string(hex_format(lower))
			file_lower.close()
			Console.ok("Saved lower hex data as " + save_dir.get_basename() + "-lower.hex")
	if prog_len <= 2048:
		Console.log("No upper hex file needed")
	else:
		var upper: String = program.slice(2048, 4096).hex_encode()
		var file_upper := FileAccess.open(save_dir.get_basename() + "-upper.hex", FileAccess.WRITE)
		if file_upper:
			file_upper.store_string(hex_format(upper))
			file_upper.close()
			Console.ok("Saved upper hex data as " + save_dir.get_basename() + "-upper.hex")
	Console.newline()
	Console.ok("Compiled successfully!")
	return 0

static func hex_format(hex: String) -> String:
	var output: String = ""
	for i in range(0, hex.length(), 2):
		output += hex[i] + hex[i + 1] + " "
		if i % 32 == 30:
			output += "\n"
	return output

static func parse_num(value: String) -> int:
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

static func validate_argument(args: Array[String], inst_mnemonic: String, num_args: int, types: Array[String], max_sizes: Array[int]) -> String:
	if args.size() != num_args:
		return "Instruction " + inst_mnemonic + " takes " + str(num_args) + " " + ("arguments" if num_args != 0 else "argument") + " but " + str(len(args)) + (" was given" if len(args) == 1 else " were given")
	for i in range(args.size()):
		if types[i] == "number":
			var num := parse_num(args[i])
			if num < 0:
				match num:
					-1:
						return "Hex constructor is empty"
					-2:
						return "Binary constructor is empty"
					-3:
						return "Invalid hex number: " + args[0]
					-4:
						return "Invalid binary number: " + args[0]
					-5:
						return "Argument is not a number"
					-6:
						return "Argument must be a positive number"
			elif num > max_sizes[i]:
				if "0b" in args[i]:
					return "Argument must be between 0 and " + str(max_sizes[i]) + " (" + str(int(floor(log(max_sizes[i]) / log(2)) + 1)) + " bits)"
				elif "0x" in args[i]:
					return "Argument must be between 0 and " + str(max_sizes[i]) + " (" + str(int(floor(log(max_sizes[i]) / log(16)) + 1)) + " hex digits)"
				return "Argument must be between 0 and " + str(max_sizes[i])
	return ""
