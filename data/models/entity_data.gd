extends Resource
class_name EntityData


@export var name := "Unnamed" : set = set_entity_name
@export var portrait: Texture2D = preload("res://assets/textures/portraits/portrait4-4x.png")

func set_entity_name(value: String):
	if value == "":
		name = "Unnamed"
	else:
		name = value


# @export var animation_resource: SpriteFrames
@export var job_data: JobData = preload("res://data/jobs/default_job_data.tres")

@export var strength: int = 10
@export var intelligence: int = 10
@export var agility: int = 10
@export var constitution: int = 10
@export var wisdom: int = 10
@export var charisma: int = 10

@export var hp: int = 10
@export var mp: int = 10
@export var sp: int = 10

func movement_range() -> int:
	return maxi(1, ceili(agility / 2.0))
