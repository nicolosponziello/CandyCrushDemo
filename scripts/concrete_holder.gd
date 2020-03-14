extends Node2D

var concrete_pieces = [];
var width = 8;
var height = 10;

var concrete = preload("res://scenes/concrete.tscn");

signal remove_concrete;

func make2dArray():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass;


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_grid_damage_concrete(board_pos):
	if concrete_pieces[board_pos.x][board_pos.y] != null:
		concrete_pieces[board_pos.x][board_pos.y].damage(1);
		if concrete_pieces[board_pos.x][board_pos.y].isDead():
			concrete_pieces[board_pos.x][board_pos.y].queue_free();
			concrete_pieces[board_pos.x][board_pos.y] = null;
			emit_signal("remove_concrete", board_pos);


func _on_grid_make_concrete(board_pos):
	if concrete_pieces.size() == 0:
		concrete_pieces = make2dArray();
	var current = concrete.instance();
	add_child(current);
	current.position = Vector2(board_pos.x * 64 + 64, -board_pos.y * 64 + 800);
	concrete_pieces[board_pos.x][board_pos.y] = current;
