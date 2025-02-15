#class_name GE
extends Node

signal GE_init
signal GE_go
signal GE_roll


# 定义常量
const GROW = 1
const MOVE = 2
const SPORE = 3

var W = 6
var H = 6
var field = []
var germs_u = []
var germs_e = []
var player_now = 1
var germs_left = []
var history = {}

func _init() -> void:
	new_field()
	roll()
	print("Game initialized with field:")
	show_field()
	print('ok')


func _ready():

	''' for testting
	# 模拟一些操作
	print("Player now: ", player_now)
	print("Germ clusters left: ", germs_left)

	# 模拟一个 GROW 操作
	var f_pos = Vector2(5, 5)
	var t_pos = Vector2(5, 4)
	print("Attempting GROW from ", f_pos, " to ", t_pos)
	var result = go(GROW, f_pos, t_pos)
	print("Result of GROW: ", result)
	show_field()

	# 模拟一个 MOVE 操作
	f_pos = Vector2(4, 4)
	t_pos = Vector2(3, 4)
	print("Attempting MOVE from ", f_pos, " to ", t_pos)
	result = go(MOVE, f_pos, t_pos)
	print("Result of MOVE: ", result)
	show_field()

	# 模拟一个 SPORE 操作
	f_pos = Vector2(0, 0)
	t_pos = Vector2(0, 2)
	print("Attempting SPORE from ", f_pos, " to ", t_pos)
	result = go(SPORE, f_pos, t_pos)
	print("Result of SPORE: ", result)
	show_field()

	# 检查游戏状态
	print("Final game state:")
	print("Player now: ", player_now)
	print("Germ clusters left: ", germs_left)
	'''

func new_field():
	field = []
	var row = []
	for i in range(W):
		row.append(0)
	for i in range(H):
		field.append(row.duplicate())
	field[0][0] = 1
	field[0][2] = 1
	field[-1][-1] = 2
	field[-2][-2] = 2

func fieldget(pos: Vector2) -> int:
	var x = pos.x
	var y = pos.y
	if y < 0 or y >= H:
		return -1 # 空气墙
	if x < 0 or x >= W:
		return -1
	return field[y][x]


func around(pos: Vector2) -> Array:
	var x = pos.x
	var y = pos.y
	return [Vector2(x - 1, y), Vector2(x + 1, y), Vector2(x, y - 1), Vector2(x, y + 1)]

func germs_inclu(pos: Vector2, germs: Array) -> Array:
	for i in range(len(germs)):
		if pos in germs[i]:
			return [i, germs[i].find(pos)]  # 返回一个数组
	return []  # 如果没有找到，返回空数组

func get_germ_from_pos(pos: Vector2, germs: Array) -> Array:
	var inclu = germs_inclu(pos,germs)
	if inclu:
		return germs[inclu[0]]
	return[]


func count(germs: Array) -> int:
	var c = 0
	for i in germs:
		c += len(i)
	return c


func roll():
	germs_pick()
	player_now = 2 if player_now == 1 else 1
	germs_left = germs_now().duplicate()  # 使用 duplicate() 创建副本
	emit_signal('GE_roll')




func germs_pick():
	germs_u = []
	germs_e = []
	for fy in range(H):
		for fx in range(W):
			var fn = fieldget(Vector2(fx, fy))
			var pos = Vector2(fx, fy)
			var germs
			if fn == 1:
				germs = germs_u
			elif fn == 2:
				germs = germs_e
			else:
				continue
			var germ_a = null
			for i in around(pos):
				var g = germs_inclu(i, germs)
				if len(g) > 0:  # 检查返回值是否有效
					germs[g[0]].append(pos)
					if germ_a and germ_a[0] != g[0]:
						var ggg = germs[germ_a[0]].duplicate()
						germs[g[0]] += ggg
						germs.remove_at(germ_a[0])
					germ_a = g
			if not germ_a:
				germs.append([pos])


func germs_now() -> Array:
	if player_now == 1:
		return germs_u
	return germs_e

func check(mode: int, f_pos: Vector2, t_pos: Vector2) -> Array:
	if mode != GROW and mode != MOVE and mode != SPORE:
		return [false, 100]
	if fieldget(f_pos) == -1:
		return [false, 101]
	if fieldget(t_pos) == -1:
		return [false, 102]
	if fieldget(f_pos) != player_now:
		return [false, 300]
	if len(germs_inclu(f_pos, germs_left)) == 0:
		return [false, 301]
	if t_pos not in allow_pick(mode, f_pos):
		return [false, 302]
	return [true, 200]

func go(mode: int, f_pos: Vector2, t_pos: Vector2) -> Array:
	var check_ = check(mode, f_pos, t_pos)
	if check_[0]:
		if mode == MOVE or mode == SPORE:
			field[f_pos.y][f_pos.x] = 0
		field[t_pos.y][t_pos.x] = player_now
		var germ_index = germs_inclu(f_pos, germs_left)
		if len(germ_index) > 0:  # 检查返回值是否有效
			germs_left.remove_at(germ_index[0])
		if len(germs_left) == 0:
			roll()
		emit_signal('GE_go') # 发送棋盘改变信号
	germs_pick()
	return check_

func allow_pick(mode: int, f_pos: Vector2) -> Array:
	if fieldget(f_pos) == player_now:
		if mode == GROW:
			return allow_pick_grow(f_pos)
		elif mode == MOVE:
			return allow_pick_move(f_pos)
		elif mode == SPORE:
			return allow_pick_spore(f_pos)
	return []

func allow_pick_grow(f_pos: Vector2) -> Array:
	var germs = germs_now()
	var i = germs_inclu(f_pos, germs)
	if len(i) == 0:
		return []
	return allow_pick_base(germs[i[0]])

func allow_pick_move(f_pos: Vector2) -> Array:
	var germs = germs_now()
	var i = germs_inclu(f_pos, germs)
	if len(i) == 0:
		return []
	return allow_pick_base(germs[i[0]]) + allow_pick_base(germs[i[0]], 1 if player_now == 2 else 2)

func allow_pick_spore(f_pos: Vector2) -> Array:
	var a1 = allow_pick_base([f_pos])
	return a1 + allow_pick_base(a1)

func allow_pick_base(germ: Array, aim: int = 0) -> Array:
	var allow = []
	for i in germ:
		for ii in around(i):
			if fieldget(ii) == aim and ii not in allow:
				allow.append(ii)
	return allow


func show_field():
	for row in field:
		print(row)
