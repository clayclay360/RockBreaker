extends Line2D

signal stop

var point


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	point = get_parent().global_position
	add_point(point)
	if points.size() > 10:
		remove_point(0)
