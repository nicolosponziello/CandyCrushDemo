extends Node2D

var ice_pieces = [];
var width = 8;
var height = 10;

var ice = preload("res://scenes/ice.tscn");

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


func _on_grid_damage_ice(board_pos):
	if ice_pieces[board_pos.x][board_pos.y] != null:
		ice_pieces[board_pos.x][board_pos.y].damage(1);
		if ice_pieces[board_pos.x][board_pos.y].isDead():
			ice_pieces[board_pos.x][board_pos.y].queue_free();
			ice_pieces[board_pos.x][board_pos.y] = null;


func _on_grid_make_ice(board_pos):
	if ice_pieces.size() == 0:
		ice_pieces = make2dArray();
	var current = ice.instance();
	add_child(current);
	current.position = Vector2(board_pos.x * 64 + 64, -board_pos.y * 64 + 800);
	ice_pieces[board_pos.x][board_pos.y] = current;
