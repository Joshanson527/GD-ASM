class_name AssemblyInstruction
extends Resource

enum EncodingType {
	STANDALONE,
	OPERAND,
	SELECT_BIT,
	SELECT_BIT_OPERAND,
	RAM_ADDRESS,
	PROG_ADDRESS
}


@export var mnemonic: String = ""
@export var color: Color = Color(1.0, 1.0, 1.0)
@export var encoding_type: EncodingType = EncodingType.STANDALONE
@export_range(0, 15) var opcode: int = 0
@export_range(0, 1) var selection_bit: int = 0
