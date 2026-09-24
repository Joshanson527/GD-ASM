class_name Console
extends Node

static var console: RichTextLabel

static func _log_message(level: String, color: String, message: String, use_prefix: bool = true, line_link: String = "", indent: String = "") -> void:
	if console:
		var prefix: String = level if use_prefix else ""
		if line_link == "":
			console.append_text(indent + "[color=#" + color + "]" + prefix + message + "[/color]\n")
		else:
			console.append_text(indent + "[url=" + line_link + "][color=#" + color + "]" + prefix + message + "[/color][/url]\n")
	else:
		print("no console")

static func log(message: String, use_prefix: bool = true, line_link: String = "", indent: String = "") -> void:
	_log_message("[INFO] ", "e0e0e0ff", message, use_prefix, line_link, indent)

static func step(message: String, use_prefix: bool = true, line_link: String = "", indent: String = "") -> void:
	_log_message("[STEP] ", "077ff8ff", message, use_prefix, line_link, indent)

static func ok(message: String, use_prefix: bool = true, line_link: String = "", indent: String = "") -> void:
	_log_message("[ OK ] ", "4ed048ff", message, use_prefix, line_link, indent)

static func warn(message: String, use_prefix: bool = true, line_link: String = "", indent: String = "") -> void:
	_log_message("[WARN] ", "d9c125ff", message, use_prefix, line_link, indent)

static func error(message: String, use_prefix: bool = true, line_link: String = "", indent: String = "") -> void:
	_log_message("[ERROR] ", "ff4939ff", message, use_prefix, line_link, indent)

static func newline() -> void:
	if console:
		console.newline()

static func clear() -> void:
	if console:
		console.clear()

static func set_auto_scroll(state: bool) -> void:
	if console:
		console.scroll_following = state
