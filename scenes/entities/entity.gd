extends Node2D
class_name Entity


@export var stats:EntityData

@onready var sprite = $AnimatedSprite2D
@onready var name_label = $NameLabel


func _ready():
	print("Entity ready:", name, stats)
	if stats and stats.animation_resource == null:
		stats.animation_resource = preload("res://assets/resources/kanji_anim.tres")
	if not Engine.is_editor_hint():
		if stats:
			name_label.text = stats.name
			if stats.animation_resource:
				sprite.sprite_frames = stats.animation_resource
		# Ensure DetectTouch and DetectKeyboard are initialized
	
	sprite.animation = "down_idle"  # Or whatever your default animation is
	sprite.play()

func _process(_delta):
	if Engine.is_editor_hint():
		if stats:
			name_label.text = stats.name
			if stats.animation_resource and sprite.sprite_frames != stats.animation_resource:
				sprite.sprite_frames = stats.animation_resource
				sprite.animation = "down_idle"
				sprite.play()
