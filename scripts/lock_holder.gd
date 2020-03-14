extends Node2D

var lock_pieces = [];
var width = 8;
var height = 10;

var lock = preload("res://scenes/licorice.tscn");

signal remove_lock;

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


func _on_grid_damage_lock(board_pos):
	if lock_pieces[board_pos.x][board_pos.y] != null:
		lock_pieces[board_pos.x][board_pos.y].damage(1);
		if lock_pieces[board_pos.x][board_pos.y].isDead():
			lock_pieces[board_pos.x][board_pos.y].queue_free();
			lock_pieces[board_pos.x][board_pos.y] = null;
			emit_signal("remove_lock", board_pos);


func _on_grid_make_lock(board_pos):
	if lock_pieces.size() == 0:
		lock_pieces = make2dArray();
	var current = lock.instance();
	add_child(current);
	current.position = Vector2(board_pos.x * 64 + 64, -board_pos.y * 64 + 800);
	lock_pieces[board_pos.x][board_pos.y] = current;
