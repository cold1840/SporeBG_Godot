extends Node

#const  SIZE_EXPAND_FILL = 60
var step_from = Vector2(0,0)
var step_mode = GECons.Mode.GROW
var pre_choose = Vector2(0,0)


func _GB_init():
	step_from = GE.germs_left[0][0]
	


func _ready():
	_GB_init()
	# 创建 GridContainer
	var grid_container = GridContainer.new()
	grid_container.columns = 6  # 设置列数
	add_child(grid_container)

	
	grid_container.custom_minimum_size = Vector2(360, 360)
	self.position = (Vector2(get_viewport().size)-Vector2(360, 360))/2#Vector2(400, 130)  # 设置棋盘位置
	

	# 动态创建 6x6 的 ColorRect
	for y in range(6):
		for x in range(6):
			var cell = ColorRect.new()
			#cell.custom_minimum_size = Vector2(60, 60)  # 设置矩形大小
			#cell.color = Color()
			cell.set_script(load("res://ColorRect_block.gd")) # 挂载脚本
			var pos = Vector2(x,y)
			cell.pos = pos
			grid_container.add_child(cell)
			
	# 窗口大小改变自适应
	get_viewport().connect('size_changed', Callable(self, '_move_to_screen_center'))



func _move_to_screen_center() -> void:
	self.position = (Vector2(get_viewport().size)-get_children()[0].size)/2

'''
func _process(_delta):
	
	# 获取 GridContainer 中的所有 ColorRect
	var grid_container = get_child(0)  # 假设 GridContainer 是第一个子节点
	var children = grid_container.get_children()
	var index = 0
	for y in range(6):
		for x in range(6):
			var cell = children[index]
			var block_value = get_node('../GE').fieldget(Vector2(x,y))
			if block_value==1:
				cell.color = Color(0,0,0)  # 更新颜色
			elif block_value==0:
				cell.color = Color(0.5,0.5,0.5)
			elif block_value==2:
				cell.color = Color(1,1,1)
			
			index += 1

'''
