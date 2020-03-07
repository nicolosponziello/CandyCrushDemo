extends Node2D

# FSM
enum {
	wait,
	move
}
var state;

# Grid Variables
export (int) var width;
export (int) var height;
export (int) var x_start;
export (int) var y_start;
export (int) var offset;
export (int) var y_offset;

#the piece array
var possible_pieces = [
	preload("res://scenes/yellow_piece.tscn"),
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/l_green_piece.tscn"),
	preload("res://scenes/orange_piece.tscn")	
];

var all_pieces = [];

# Swap back
var piece_one = null;
var piece_two = null;
var last_place = Vector2(0,0);
var last_dir = Vector2(0,0);
var move_check = false;

# Touch
var first_touch = Vector2(0,0);
var final_touch = Vector2(0,0);
var controlling = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	state = move;
	randomize();
	all_pieces = make2dArray();
	spawn_pices();

func make2dArray():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

func grid_to_pixel(col, row):
	var new_x = x_start + offset * col;
	var new_y = y_start + -offset * row;
	return Vector2(new_x, new_y);

func spawn_pices():
	for i in width:
		for j in height:
			var random = generate_random();
			#create the piece
			var piece = possible_pieces[random].instance();
			while(match_at(i, j, piece.color)):
				random = generate_random();
				piece = possible_pieces[random].instance();
			add_child(piece);
			piece.position = grid_to_pixel(i, j);
			all_pieces[i][j] = piece;

func store_info(first_piece, other_piece, place, dir):
	piece_one = first_piece;
	piece_two = other_piece;
	last_place = place;
	last_dir = dir;

func swap_back():
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_dir);
	state = move;
	move_check = false;
			
func match_at(col, row, color):
	if col > 1:
		if all_pieces[col - 1][row] != null && all_pieces[col - 2][row] != null:
			if all_pieces[col-1][row].color == color && all_pieces[col -2][row].color == color:
				return true;
	if row > 1:
		if all_pieces[col][row-1] != null && all_pieces[col][row-2] != null:
			if all_pieces[col][row-1].color == color && all_pieces[col][row-2].color == color:
				return true;
	return false;
				
func generate_random():
	return floor(rand_range(0, possible_pieces.size()));
	
func pixel_to_grid(x, y):
	var col = round((x - x_start) / offset);
	var row = round((y - y_start) / -offset);
	if row == -0:
		row = 0;
	if col == -0:
		col = 0;
	return Vector2(col, row);
	
func is_in_grid(col, row):
	if col >= 0 && col < width:
		if row >= 0 && row < height:
			return true;
	return false;
	
func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		var touch_pos = get_global_mouse_position();
		touch_pos = pixel_to_grid(touch_pos.x, touch_pos.y);
		if is_in_grid(touch_pos.x, touch_pos.y):
			controlling = true;
			first_touch = touch_pos;
		
	if Input.is_action_just_released("ui_touch"):
		var touch_pos_released = get_global_mouse_position();
		touch_pos_released = pixel_to_grid(touch_pos_released.x, touch_pos_released.y);
		if(is_in_grid(touch_pos_released.x, touch_pos_released.y) && 
			controlling && !check_same_piece(first_touch, touch_pos_released)):
			final_touch = touch_pos_released;
			touch_diff(first_touch, final_touch);
			controlling = false;
			
func check_same_piece(pos1, pos2):
	return pos1.x == pos2.x && pos1.y == pos2.y;

func swap_pieces(col, row, direction):
	var first = all_pieces[col][row];
	var second = all_pieces[col + direction.x][row + direction.y];
	if first != null && second != null:
		store_info(first, second, Vector2(col, row), direction);
		state = wait;
		all_pieces[col][row] = second;
		all_pieces[col + direction.x][row + direction.y] = first;
		first.move(grid_to_pixel(col + direction.x, row + direction.y));
		second.move(grid_to_pixel(col, row));
		if !move_check:
			find_matches();
	
func touch_diff(grid_1, grid_2):
	var diff = grid_2 - grid_1;
	if abs(diff.x) > abs(diff.y):
		if diff.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0));
		elif diff.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0));
	elif abs(diff.y) > abs(diff.x):
		if diff.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1));
		elif diff.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1));
			
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if state == move:
		touch_input();
	
func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var currentColor = all_pieces[i][j].color;
				#check left/right
				if i >  0 && i < width -1:
					if all_pieces[i-1][j] != null && all_pieces[i+1][j] != null:
						if all_pieces[i-1][j].color == currentColor && all_pieces[i+1][j].color == currentColor:
							print("Match horizontal!");
							all_pieces[i-1][j].dim();
							all_pieces[i][j].dim();
							all_pieces[i+1][j].dim();
							all_pieces[i-1][j].matched = true;
							all_pieces[i][j].matched = true;
							all_pieces[i+1][j].matched = true;
				if j > 0 && j < height-1:
					if all_pieces[i][j-1] != null && all_pieces[i][j+1] != null:
						if all_pieces[i][j-1].color == currentColor && all_pieces[i][j+1].color == currentColor:
							print("Match vertical!");
							all_pieces[i][j-1].dim();
							all_pieces[i][j].dim();
							all_pieces[i][j+1].dim();
							all_pieces[i][j-1].matched = true;
							all_pieces[i][j].matched = true;
							all_pieces[i][j+1].matched = true;
	get_parent().get_node("destroy_timer").start();

func destroy_matched():
	var found_match = false;
	for i in width: 
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					found_match = true;
					all_pieces[i][j].queue_free();
					all_pieces[i][j] =null;
	move_check = true;
	if found_match:
		get_parent().get_node("collapse_timer").start();
	else:
		swap_back();

func collapse_cols():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j+1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j));
						all_pieces[i][j] = all_pieces[i][k];
						all_pieces[i][k] = null;
						break;
	get_parent().get_node("refill_timer").start();

func refill_cols():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var random = generate_random();
				#create the piece
				var piece = possible_pieces[random].instance();
				while(match_at(i, j, piece.color)):
					random = generate_random();
					piece = possible_pieces[random].instance();
				add_child(piece);
				piece.position = grid_to_pixel(i, j + y_offset);
				piece.move(grid_to_pixel(i, j));
				all_pieces[i][j] = piece;
	after_refill();

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color):
					find_matches();
					get_parent().get_node("destroy_timer").start();
					break;
	move_check = false;

func _on_destroy_timer_timeout():
	destroy_matched();


func _on_collapse_timer_timeout():
	collapse_cols();


func _on_refill_timer_timeout():
	refill_cols();
	state = move;
