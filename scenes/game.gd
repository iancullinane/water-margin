extends Node2D

@export var height: int;
@export var width: int;


var grid: Array

# func _ready():
# 	# Initialize the 2D array based on height and width
# 	grid = []
# 	for y in range(height):
# 		var row = []
# 		for x in range(width):
# 			row.append(null)
# 		grid.append(row)
