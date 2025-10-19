@tool
extends Node2D
class_name Entity_V2


@export var stats:EntityData

var CELL_SIZE = GameConstants.CELL_SIZE

@onready var sprite = $AnimatedSprite2D
@onready var name_label = $NameLabel





