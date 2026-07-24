extends Object
class_name logging

static func log(s: String) -> void:
	print_rich("[color=BBB825]INF:[/color] %s" % s)

static func warn(s: String) -> void:
	print_rich("[color=FE712F]WARN:[/color] %s" % s)

static func err(s: String) -> void:
	print_rich("[color=FF4444]ERR:[/color] %s" % s)

static func success(s: String) -> void:
	print_rich("[color=44FF88]OK:[/color] %s" % s)
