extends ColorRect


var pos: Vector2
var scale_aim = Vector2(1,1)
var color_aim = Color(0.5,0.5,0.5)
var chosen_type: int = 0 #0未被选中 1被选中 2作为菌落成员被选中
var light = PointLight2D.new()
var light_color_aim = Color(1,1,1)
var GB:Node
var err_click_act = false

# Called when the node enters the scene tree for the first time.
func _ready():
	GB = get_node("../..")  # 与棋盘对象创建连接
	GE.connect('GE_go', Callable(self, '_fresh'))
	GE.connect('GE_roll', Callable(self, '_fresh'))
	get_parent().connect('gui_input', Callable(self, '_fresh_input'))
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	self.connect("mouse_entered",Callable(self, "_on_cell_mouse_entered"))
	self.connect("mouse_exited", Callable(self, "_on_cell_mouse_exited"))
	color_set_back()
	scale_set_back()
	await get_tree().process_frame # 等待一帧后Grid容器为其赋予size
	set_pivot_offset(self.size/2) # 设置缩放中心居中
	# 创建一个PointLight2D节点为子
	# 创建一个点光源
	#light = PointLight2D.new()
	light.texture = load("res://LSPoint.webp")
	light.z_index = 2
	add_child(light)
	light.position = size/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	set_scale(get_scale()+(scale_aim - get_scale())*0.5)
	set_color(get_color()+(color_aim - get_color())*0.1)
	light.set_color(light.get_color()+(light_color_aim - light.get_color())*0.08)
	chosen_type_update()
	light_update()
	#get_tree().root.get_node('Node2D/Label').set_text(str(_delta)) #test

func light_update():
	if pos in GE.allow_pick(GB.step_mode, GB.step_from):#提示可以往这走棋
		light_color_aim = Color(0,1,0)
	elif err_click_act:                                 # 错误操作提示
		light_color_aim = Color(1,0,0) 
		light.color = Color(0.7,0,0)   # 很急
		light.blend_mode = 0
		light.energy = 1.3
	elif pos==GB.pre_choose:                            # 鼠标浮在这里
		light_color_aim = Color(1,1,1)
		light.blend_mode = 1
		light.energy = 0.3
	elif GE.fieldget(pos)==0:                           # 空位 不发光
		light_color_aim = Color(0,0,0)
		light.blend_mode = 0
		light.energy = 0.7
	else:
		light_color_aim = color  # 设置光源颜色为白色
		light.blend_mode = 0
		light.energy = 0.7
	#light.energy = 0.7  # 设置光源强度
	light.texture_scale = (float(70)/float(256))  # 设置光源范围


func chosen_type_update():
	var type_old = chosen_type
	if GB.step_from==pos:
		chosen_type = 1
	elif pos in GE.get_germ_from_pos(GB.step_from,GE.germs_left):
		chosen_type = 2
	else:
		chosen_type = 0
	if chosen_type!=type_old:
		scale_set_back()

func color_set_back():
	var block_value = GE.fieldget(pos)
	if block_value==1:
		color_aim = Color(0.8,0.8,0.6)  # 更新颜色
	elif block_value==0:
		color_aim = Color(0.5,0.5,0.5)
	elif block_value==2:
		color_aim = Color(0.6,0.8,0.8)

func scale_set_back():
	if chosen_type==1:
		scale_aim = Vector2(1.2,1.2)
		z_index = 5
	elif chosen_type==2:
		scale_aim = Vector2(1.1,1.1)
		z_index = 0
	else:
		scale_aim = Vector2(1,1)
		z_index = 0

func _on_cell_mouse_exited():
	print(pos)
	color_set_back()
	scale_set_back()

func _on_cell_mouse_entered():
	color_aim = Color(0.6, 0.6, 0.6)  # 高亮颜色
	scale_aim = Vector2(1.04,1.04)
	GB.pre_choose = pos
	
'''
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT:
			if event.pressed:
				print('按下',pos)
'''

func _fresh():
	print('fresh')
	color_set_back()

func _fresh_input(event: InputEvent):
	if event is InputEventMouseButton:
		_fresh()
	


func click() -> Array:
	if GB.step_from==pos:
		if GB.step_mode==GE.GROW:
			GB.step_mode = GE.MOVE
		elif GB.step_mode==GE.MOVE:
			GB.step_mode = GE.SPORE
		elif GB.step_mode==GE.SPORE:
			GB.step_mode = GE.GROW
	if GE.germs_inclu(pos, GE.germs_left):
		GB.step_from = pos
	elif pos in GE.allow_pick(GB.step_mode, GB.step_from):
		GE.go(GB.step_mode, GB.step_from, pos)
		if len(GE.germs_left)>0:
			GB.step_from = GE.germs_left[0][0]
			return [GB.step_mode, GB.step_from, pos]
	else:
		GB.step_from = GE.germs_left[0][0]
		GB.step_mode = GE.GROW
	return []
	

func _gui_input(event):
	if event is InputEventMouse:
		pass
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT:
			if event.pressed:
				print('按下',pos)
				scale_aim = Vector2(0.9,0.9)
				var click_result = click()
				if GE.fieldget(pos)==0 and not click_result: # 点到空处且点击操作无效
					err_click_act = true
			else: # 松开
				scale_set_back()
				#scale_aim = Vector2(1,1)
				err_click_act = false # 松开过去 就原谅你吧
