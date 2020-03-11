extends Node2D

export (int) var health;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func damage(amount):
	if health > 0:
		health -= amount;
		# particles here

func isDead():
	return health <= 0;
