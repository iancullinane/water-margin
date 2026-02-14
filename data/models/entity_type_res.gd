extends Resource
class_name EntityTypeResource

@export var entity_class: String = "Warrior"
@export_multiline var description: String = "A basic warrior class"

# # Visual
# @export var class_icon: Texture2D
# @export var sprite_sheet: Texture2D
# @export var animation_set: String = "warrior"  # Reference to which animations to use

# # Combat capabilities
# @export var base_attack_range: int = 1  # How many tiles away can attack
# @export var base_movement_range: int = 4  # How many tiles can move per turn
# @export var can_attack_diagonally: bool = false
# @export var can_move_diagonally: bool = true

# # Equipment restrictions
# @export var allowed_weapon_types: Array[String] = ["sword", "axe"]
# @export var allowed_armor_types: Array[String] = ["light", "medium"]
# @export var can_use_shields: bool = true
# @export var can_dual_wield: bool = false

# # Class abilities
# @export var abilities: Array[String] = []  # List of ability names this class can use
# @export var starting_ability: String = ""  # Ability available from level 1

# # Stat modifiers (applied on top of base entity stats)
# @export_group("Stat Modifiers")
# @export var strength_modifier: int = 0
# @export var intelligence_modifier: int = 0
# @export var agility_modifier: int = 0
# @export var constitution_modifier: int = 0
# @export var wisdom_modifier: int = 0
# @export var charisma_modifier: int = 0

# # Growth rates (affects stat gains on level up)
# @export_group("Growth Rates %")
# @export_range(0, 100) var strength_growth: int = 50
# @export_range(0, 100) var intelligence_growth: int = 50
# @export_range(0, 100) var agility_growth: int = 50
# @export_range(0, 100) var constitution_growth: int = 50
# @export_range(0, 100) var wisdom_growth: int = 50
# @export_range(0, 100) var charisma_growth: int = 50

# # Special class traits
# @export_group("Class Traits")
# @export var has_counter_attack: bool = false
# @export var has_ranged_counter: bool = false
# @export var can_attack_twice: bool = false
# @export var ignores_terrain_penalty: bool = false
# @export var bonus_crit_chance: float = 0.0
# @export var bonus_accuracy: float = 0.0
# @export var bonus_evasion: float = 0.0

# # Class promotion/advancement
# @export_group("Advancement")
# @export var can_promote: bool = true
# @export var promotion_level: int = 10
# @export var promotes_to: Array[ClassData] = []  # Classes this can promote to
# @export var promotion_item_required: String = ""  # Item needed for promotion

# func get_total_stat(base_value: int, stat_name: String) -> int:
# 	match stat_name:
# 		"strength":
# 			return base_value + strength_modifier
# 		"intelligence":
# 			return base_value + intelligence_modifier
# 		"agility":
# 			return base_value + agility_modifier
# 		"constitution":
# 			return base_value + constitution_modifier
# 		"wisdom":
# 			return base_value + wisdom_modifier
# 		"charisma":
# 			return base_value + charisma_modifier
# 		_:
# 			return base_value

# func can_equip_weapon(weapon_type: String) -> bool:
# 	return weapon_type in allowed_weapon_types

# func can_equip_armor(armor_type: String) -> bool:
# 	return armor_type in allowed_armor_types

# func can_use_ability(ability_name: String) -> bool:
# 	return ability_name in abilities

# func get_growth_rate(stat_name: String) -> int:
# 	match stat_name:
# 		"strength":
# 			return strength_growth
# 		"intelligence":
# 			return intelligence_growth
# 		"agility":
# 			return agility_growth
# 		"constitution":
# 			return constitution_growth
# 		"wisdom":
# 			return wisdom_growth
# 		"charisma":
# 			return charisma_growth
# 		_:
# 			return 50  # Default growth rate
