@abstract
class_name CardData
extends Resource

enum CardType{
	ATTACK,
	SKILL,
	STATUS,
	POWER
}

@export var name: String = ""
@export var type: CardType
@export var cost: int = 1
@export var icon: Texture2D
@export var override_auto_generated_description: bool = false
@export_multiline var special_description: String = ""

@export var tooltip_statuses: Array[StatusEffect] = []

class CastData:
	var caster: Character
	var opponent: Character

@abstract
func get_description(data: CastData) -> String

@abstract
func cast (data : CastData)

@abstract
func get_preview_text(data: CastData = null) -> String

@abstract
func check_cast_condition() -> bool
