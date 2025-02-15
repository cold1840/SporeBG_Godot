extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


enum Mode {
	GROW = 1,
	MOVE = 2,
	SPORE = 3
}

func mode_str(mode: int) -> String:
	match mode:
		Mode.GROW:
			return "GROW"
		Mode.MOVE:
			return "MOVE"
		Mode.SPORE:
			return "SPORE"
	return ""

func mode_str_ch(mode: int) -> String:
	match mode:
		Mode.GROW:
			return "生长"
		Mode.MOVE:
			return "移动"
		Mode.SPORE:
			return "孢子"
	return ""
