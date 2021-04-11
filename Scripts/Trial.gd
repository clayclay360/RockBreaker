extends Line2D

signal stop

var point


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true) # top level to true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	point = get_parent().global_position # set point to parent's global position
	add_point(point) # run the add point function with the agrument point
	if points.size() > 10:
		remove_point(0) # remove the first point
