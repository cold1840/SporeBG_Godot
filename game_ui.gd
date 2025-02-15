extends Node



var mode_now: int = GECons.Mode.GROW

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mode_now_update()

func mode_now_update(): # 用于更新ModeNow节点的内容
	$ModeNow.set_text(GECons.mode_str_ch($"../GameBoard".step_mode))
	
