extends Node2D


export (String) var color; #color of the piece, export allow the var to be visible in the inspector 

var move_tween;

# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = get_node("move_tween");
	
func move(target):
	move_tween.interpolate_property(self, "position", position, target, .3,
				Tween.TRANS_QUART, Tween.EASE_OUT);
	move_tween.start();


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
