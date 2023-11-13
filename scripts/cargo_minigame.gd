extends Node2D

"""
Below are the configurables.
"""

const N := 3 # HEIGHT
const M := 4 # WIDTH
const MAX_BLOCK := 4 # biggest block e.g. 4 for tetromino

const BLOCK_SIZE_IN_PIXELS := 200

const SPAWN_POOL_HEIGHT := 5
const SPAWN_POOL_WIDTH := 5

"""
I've separated readable high-level code from unreadable code.
Readable code below.
"""

# on closing: complete is the only winning state
enum CargoMiniGameState {startup, unselected, selected, complete}
var selected_block_node: Sprite2D = null
var selected_block_type: Block = Block.unknown
var current_game_state := CargoMiniGameState.startup

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_connections()
	# print_graph()
	get_pieces()
	get_blocks()
	"""
	for b in blocks:
		print(Block.keys()[b])
	"""
	create_block_nodes()
	
	for i in range(N):
		cell_occupation.push_back([])
		for j in range(M):
			cell_occupation[i].push_back(false)
	
	current_game_state = CargoMiniGameState.unselected

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_game_state == CargoMiniGameState.selected and selected_block_node != null:
		selected_block_node.position = get_local_mouse_position()
		

const BLOCK_SPRITES_TABLE := [
	preload("res://sprites/cargo_minigame/single.png"),
	preload("res://sprites/cargo_minigame/double_horizontal.png"),
	preload("res://sprites/cargo_minigame/double_vertical.png"),
	preload("res://sprites/cargo_minigame/triple_horizontal.png"),
	preload("res://sprites/cargo_minigame/triple_vertical.png"),
	preload("res://sprites/cargo_minigame/triple_square_minus_top_left.png"),
	preload("res://sprites/cargo_minigame/triple_square_minus_top_right.png"),
	preload("res://sprites/cargo_minigame/triple_square_minus_bottom_left.png"),
	preload("res://sprites/cargo_minigame/triple_square_minus_bottom_right.png"),
	preload("res://sprites/cargo_minigame/tetris_i_horizontal.png"),
	preload("res://sprites/cargo_minigame/tetris_i_vertical.png"),
	preload("res://sprites/cargo_minigame/tetris_o.png"),
	preload("res://sprites/cargo_minigame/tetris_l.png"),
	preload("res://sprites/cargo_minigame/tetris_l_upside_down.png"),
	preload("res://sprites/cargo_minigame/tetris_l_hook_down.png"),
	preload("res://sprites/cargo_minigame/tetris_l_hook_up.png"),
	preload("res://sprites/cargo_minigame/tetris_j.png"),
	preload("res://sprites/cargo_minigame/tetris_j_upside_down.png"),
	preload("res://sprites/cargo_minigame/tetris_j_hook_down.png"),
	preload("res://sprites/cargo_minigame/tetris_j_hook_up.png"),
	preload("res://sprites/cargo_minigame/tetris_s.png"),
	preload("res://sprites/cargo_minigame/tetris_s_vertical.png"),
	preload("res://sprites/cargo_minigame/tetris_z.png"),
	preload("res://sprites/cargo_minigame/tetris_z_vertical.png"),
	preload("res://sprites/cargo_minigame/tetris_t_up.png"),
	preload("res://sprites/cargo_minigame/tetris_t_down.png"),
	preload("res://sprites/cargo_minigame/tetris_t_left.png"),
	preload("res://sprites/cargo_minigame/tetris_t_right.png")
]

"""
Spaghetti code starts here.

I don't recommend anybody ever try to understand this code, not
even future me.

-Rose
"""

func piece_can_place(block: Block, i: int, j: int):
	var shape: Array = SHAPE_TABLE[block]
	for point in shape:
		if i+point[0] < 0 or i+point[0] >= N or j+point[1] < 0 or j+point[1] >= M:
			return false 
		if cell_occupation[i+point[0]][j+point[1]]:
			return false
	return true
	
var cell_occupation: Array = []
var cells_occupied_by_given_blocks = {}

# handles snapping
func release_block():
	var board_node := get_node("board")
	var board_width: int = board_node.texture.get_width() * board_node.scale.x
	var board_height: int = board_node.texture.get_height() * board_node.scale.y
	var board_x: int = board_node.position.x - board_width / 2
	var board_y: int = board_node.position.y - board_height / 2
	
	var block_width: int = selected_block_node.texture.get_width() * selected_block_node.scale.x
	var block_height: int = selected_block_node.texture.get_height() * selected_block_node.scale.y
	var block_x: int = selected_block_node.position.x - block_width / 2
	var block_y: int = selected_block_node.position.y - block_height / 2
	
	var x_pos = block_x - board_x
	var y_pos = block_y - board_y

	var j := int(roundf(float(x_pos) / BLOCK_SIZE_IN_PIXELS))
	var i := int(roundf(float(y_pos) / BLOCK_SIZE_IN_PIXELS))

	if (piece_can_place(selected_block_type, i, j)):
		var shape: Array = SHAPE_TABLE[selected_block_type]
		if not cells_occupied_by_given_blocks.has(selected_block_node):
			cells_occupied_by_given_blocks[selected_block_node] = []
		for point in shape:
			cell_occupation[i+point[0]][j+point[1]] = true
			cells_occupied_by_given_blocks[selected_block_node].push_back([i+point[0], j+point[1]])
		selected_block_node.position.x = board_x + j * BLOCK_SIZE_IN_PIXELS + block_width / 2
		selected_block_node.position.y = board_y + i * BLOCK_SIZE_IN_PIXELS + block_height / 2
		
		# check if game is complete
		for i2 in range(N):
			for j2 in range(M):
				if cell_occupation[i2][j2] == false:
					return
		current_game_state = CargoMiniGameState.complete
		print("done!")
				

func sprite_contains_point(s: Sprite2D, p: Vector2):
	var width := s.texture.get_width() * s.scale.x
	var height := s.texture.get_height() * s.scale.y
	var xmin := s.position.x - width / 2
	var ymin := s.position.y
	return (s.position.x - width/2 <= p.x and p.x <= s.position.x + width/2
		and s.position.y - height/2 <= p.y and p.y <= s.position.y + height/2)

func _on_button_button_up():
	if current_game_state == CargoMiniGameState.selected:
		current_game_state = CargoMiniGameState.unselected
	if selected_block_node != null:
		release_block()

func _on_button_button_down():
	var mouse_pos := get_local_mouse_position()
	if current_game_state == CargoMiniGameState.unselected:
		for i in range(block_nodes.size()):
			if sprite_contains_point(block_nodes[i], mouse_pos):
				current_game_state = CargoMiniGameState.selected
				selected_block_node = block_nodes[i]
				selected_block_type = blocks[i]
				if cells_occupied_by_given_blocks.has(selected_block_node):
					for cell in cells_occupied_by_given_blocks[selected_block_node]:
						cell_occupation[cell[0]][cell[1]] = false
					cells_occupied_by_given_blocks[selected_block_node] = []
				return

	
var block_nodes: Array = []

func create_block_nodes():
	var spawn_pool := get_node("spawn_pool")
	var pool_width: int = spawn_pool.texture.get_width() * spawn_pool.scale.x
	var pool_height: int = spawn_pool.texture.get_height() * spawn_pool.scale.y
	var xmin: int = spawn_pool.position.x - pool_width / 2
	var ymin: int = spawn_pool.position.y - pool_height / 2
	var xmax: int = xmin + pool_width
	var ymax: int = ymin + pool_height
	for block in blocks:
		var sprite := Sprite2D.new()
		sprite.texture = BLOCK_SPRITES_TABLE[block]
		add_child(sprite)
		
		var block_xmin := xmin + sprite.texture.get_width() / 2
		var block_ymin := ymin + sprite.texture.get_height() / 2
		var block_xmax := xmax - sprite.texture.get_width() / 2
		var block_ymax := ymax - sprite.texture.get_height() / 2

		sprite.position.x = randf_range(block_xmin, block_xmax)
		sprite.position.y = randf_range(block_ymin, block_ymax)
		
		sprite.z_index = Block.unknown - block
		
		block_nodes.push_back(sprite)
	
const BLOCK_WIDTHS := [
	1,
	2,
	1,
	3,
	1,
	2,
	2,
	2,
	2,
	4,
	1,
	2,
	2,
	2,
	3,
	3,
	2,
	2,
	3,
	3,
	3,
	2,
	3,
	2,
	3, # direction refer to the direction of the T's nipple
	3,
	2,
	2
]

const BLOCK_HEIGHTS := [
	1,
	1,
	2,
	1,
	3,
	2,
	2,
	2,
	2,
	1,
	4,
	2,
	3,
	3,
	2,
	2,
	3,
	3,
	2,
	2,
	2,
	3,
	2,
	3,
	2, # direction refer to the direction of the T's nipple
	2,
	3,
	3
]

enum Block {
	single,
	double_horizontal,
	double_vertical,
	triple_horizontal,
	triple_vertical,
	triple_square_minus_top_left,
	triple_square_minus_top_right,
	triple_square_minus_bottom_left,
	triple_square_minus_bottom_right,
	tetris_i_horizontal,
	tetris_i_vertical,
	tetris_o,
	tetris_l,
	tetris_l_upside_down,
	tetris_l_hook_down,
	tetris_l_hook_up,
	tetris_j,
	tetris_j_upside_down,
	tetris_j_hook_down,
	tetris_j_hook_up,
	tetris_s,
	tetris_s_vertical,
	tetris_z,
	tetris_z_vertical,
	tetris_t_up, # direction refers to the direction of the T's nipple
	tetris_t_down,
	tetris_t_left,
	tetris_t_right,
	unknown
}

var possible_connections = {}
var connections = [] # pseudo-adjacency list, indexed by (i, j) then by direction

var blocks: Array = []
func get_blocks():
	for p in pieces:
		blocks.push_back(piece_to_block(p))
	blocks.sort()

var pieces := [] 
func get_pieces():
	var visited := {}
	for i in range(N):
		for j in range(M):
			if not visited.has([i, j]):
				var block: Dictionary = dfs([i, j])
				pieces.push_back(block.keys())
				for x in block:
					visited[x] = null
	

# THIS ONE HAS NO NEGATIVES
const SHAPE_TABLE := [
	[[0, 0]],
	[[0, 0], [0, 1]],
	[[0, 0], [1, 0]],
	[[0, 0], [0, 1], [0, 2]],
	[[0, 0], [1, 0], [2, 0]],
	[[0, 1], [1, 0], [1, 1]],
	[[0, 0], [1, 0], [1, 1]],
	[[0, 0], [0, 1], [1, 1]],
	[[0, 0], [0, 1], [1, 0]],
	[[0, 0], [0, 1], [0, 2], [0, 3]],
	[[0, 0], [1, 0], [2, 0], [3, 0]],
	[[0, 0], [0, 1], [1, 0], [1, 1]],
	[[0, 0], [1, 0], [2, 0], [2, 1]],
	[[0, 0], [0, 1], [1, 1], [2, 1]],
	[[0, 0], [0, 1], [0, 2], [1, 0]],
	[[0, 2], [1, 0], [1, 1], [1, 2]],
	[[0, 1], [1, 1], [2, 1], [2, 0]],
	[[0, 0], [0, 1], [1, 0], [2, 0]],
	[[0, 0], [0, 1], [0, 2], [1, 2]],
	[[0, 0], [1, 0], [1, 1], [1, 2]],
	[[1, 0], [1, 1], [0, 1], [0, 2]],
	[[0,  0], [1, 0], [1, 1], [2, 1]],
	[[0, 0], [0, 1], [1, 1], [1, 2]],
	[[0, 1], [1, 1], [1, 0], [2, 0]],
	[[0, 1], [1, 0], [1, 1], [1, 2]],
	[[0, 0], [0, 1], [0, 2], [1, 1]],
	[[0, 1], [1, 0], [1, 1], [2, 1]],
	[[0, 0], [1, 0], [1, 1], [2, 0]]
]

# THIS ONE HAS NEGATIVES
const BLOCK_TABLE := {
	[[0, 0]]: Block.single,
	[[0, 0], [0, 1]]: Block.double_horizontal,
	[[0, 0], [1, 0]]: Block.double_vertical,
	[[0, 0], [1, 0], [1, 1]]: Block.triple_square_minus_top_right,
	[[0, 0], [1, -1], [1, 0]]: Block.triple_square_minus_top_left,
	[[0, 0], [0, 1], [1, 0]]: Block.triple_square_minus_bottom_right,
	[[0, 0], [0, 1], [1, 1]]: Block.triple_square_minus_bottom_left,
	[[0, 0], [1, 0], [2, 0]]: Block.triple_vertical,
	[[0, 0], [0, 1], [0, 2]]: Block.triple_horizontal,
	[[0, 0], [1, 0], [2, -1], [2, 0]]: Block.tetris_j,
	[[0, 0], [0, 1], [1, 0], [2, 0]]: Block.tetris_j_upside_down,
	[[0, 0], [0, 1], [0, 2], [1, 2]]: Block.tetris_j_hook_down,
	[[0, 0], [1, 0], [1, 1], [1, 2]]: Block.tetris_j_hook_up,
	[[0, 0], [1, 0], [2, 0], [2, 1]]: Block.tetris_l,
	[[0, 0], [0, 1], [1, 1], [2, 1]]: Block.tetris_l_upside_down,
	[[0, 0], [0, 1], [0, 2], [1, 0]]: Block.tetris_l_hook_down,
	[[0, 0], [1, -2], [1, -1], [1, 0]]: Block.tetris_l_hook_up,
	[[0, 0], [0, 1], [1, 0], [1, 1]]: Block.tetris_o,
	[[0, 0], [0, 1], [0, 2], [0, 3]]: Block.tetris_i_horizontal,
	[[0, 0], [1, 0], [2, 0], [3, 0]]: Block.tetris_i_vertical,
	[[0, 0], [1, 0], [1, 1], [2, 0]]: Block.tetris_t_right,
	[[0, 0], [1, -1], [1, 0], [2, 0]]: Block.tetris_t_left,
	[[0, 0], [1, -1], [1, 0], [1, 1]]: Block.tetris_t_up,
	[[0, 0], [0, 1], [0, 2], [1, 1]]: Block.tetris_t_down,
	[[0, 0], [0, 1], [1, 1], [1, 2]]: Block.tetris_z,
	[[0, 0], [1, -1], [1, 0], [2, -1]]: Block.tetris_z_vertical,
	[[0, 0], [0, 1], [1, -1], [1, 0]]: Block.tetris_s,
	[[0, 0], [1, 0], [1, 1], [2, 1]]: Block.tetris_s_vertical
}	

func piece_to_block(piece: Array):
	piece.sort()
	var dy: int = piece[0][0]
	var dx: int = piece[0][1]
	for i in range(piece.size()):
		piece[i] = [piece[i][0] - dy, piece[i][1] - dx]
	if BLOCK_TABLE.has(piece):
		return BLOCK_TABLE[piece]
	print(piece)
	print("^ A WEIRD THING HAPPENED: COULDNT IDENTIFY THIS PIECE")
	return Block.unknown
	
func is_in_bounds(point: Array):
	return 0 <= point[0] and point[0] < N and 0 <= point[1] and point[1] < M

const directions := [[0, 1], [-1, 0], [0, -1], [1, 0]];

func get_direction(s: Array, t: Array):
	if (t[0] == s[0] + 1 and t[1] == s[1]):
		return 3
	elif (t[0] == s[0] - 1 and t[1] == s[1]):
		return 1
	elif t[0] == s[0] and t[1] == s[1] + 1:
		return 0
	elif t[0] == s[0] and t[1] == s[1] - 1:
		return 2
	print("a really bad thing happened and my error handling is just to cry")
	return 0

func go_in_direction(point: Array, direction: int):
	return [point[0] + directions[direction][0], point[1] + directions[direction][1]]

func dfs(start: Array):
	var to_visit = {start: null}
	var visited = {}

	while (to_visit.size() != 0):
		var point: Array = to_visit.keys()[0] # TODO: there has to be a fucking way to pop one item from a dict in godot
		to_visit.erase(point)
		if (visited.has(point)):
			continue
		for i in range(4):
			var next_point: Array = go_in_direction(point, i)
			if is_in_bounds(next_point):
				if connections[point[0]][point[1]][i]:
					to_visit[next_point] = null
		visited[point] = null
	return visited

func generate_connections():
	for i in range(N):
		connections.push_back([])
		for j in range(M):
			connections[i].push_back([false, false, false, false])

	var candidates: Array = []
	for i in range(N):
		for j in range(M):
			for k in range(4):
				var point := [i, j]
				var next_point: Array = go_in_direction(point, k)
				if is_in_bounds(next_point):
					candidates.push_back([point, next_point])
	
	candidates.shuffle()
	while candidates.size() != 0:
		var candidate: Array = candidates.pop_back()

		# make sure they aren't already connected
		var s1: Dictionary = dfs(candidate[0])
		if s1.has(candidate[1]):
			continue
		var s2: Dictionary = dfs(candidate[1])

		#make sure the combined sets won't be too big
		if s1.size() + s2.size() > MAX_BLOCK:
			continue

		var p1_to_p2_direction = get_direction(candidate[0], candidate[1])
		var p2_to_p1_direction = get_direction(candidate[1], candidate[0])
		connections[candidate[0][0]][candidate[0][1]][p1_to_p2_direction] = true
		connections[candidate[1][0]][candidate[1][1]][p2_to_p1_direction] = true
func print_graph():
	for i in range(N):
		# print row
		var row_text := ""
		for j in range(M-1):
			row_text += "*"
			if connections[i][j][0] != connections[i][j+1][2]:
				print("yikes something went really wrong")
			row_text += "-" if connections[i][j][0] else " "
		row_text += "*"
		print(row_text)
		row_text = ""

		# print all columns
		if i == N - 1:
			break

		for j in range(M):
			if connections[i][j][3] != connections[i+1][j][1]:
				print("yikes something bad happened here")
			row_text += "|" if connections[i][j][3] else " "
			row_text += " "
		print(row_text)
		row_text = ""
