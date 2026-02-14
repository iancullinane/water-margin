extends Resource
class_name EntityData


@export var name := "Unnamed" : set = set_entity_name

func set_entity_name(value: String):
	if value == "":
		name = "Unnamed"
	else:
		name = value


# @export var animation_resource: SpriteFrames
@export var job_data: JobData : set = set_job_data, get = get_job_data

func set_job_data(value: JobData):
	job_data = value

func get_job_data() -> JobData:
	if job_data == null:
		return preload("res://data/jobs/default_job_data.tres")
	return job_data

@export var strength: int = 10
@export var intelligence: int = 10
@export var agility: int = 10
@export var constitution: int = 10
@export var wisdom: int = 10
@export var charisma: int = 10

@export var hp: int = 10
@export var mp: int = 10
@export var sp: int = 10
