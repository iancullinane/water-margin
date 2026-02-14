extends Resource
class_name JobData

@export var job_name: String
@export var description: String

@export var damage: int

func _init(p_job_name = "", p_description= "", p_damage = 1):
	job_name = p_job_name
	description = p_description
	damage = p_damage
