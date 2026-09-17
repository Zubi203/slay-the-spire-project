@abstract
class_name StatusEffect
extends Resource

enum Type {
	BUFF,
	DEBUFF
}

enum ExpireOn {
	TURN_END,
	TURN_START
}

@export var buff_type: Type
@export var expire_on: ExpireOn
@export var name: String = ""
@export var base_duration: int = 3
@export var icon: Texture2D = null
@export var override_base_description: bool = false
@export_multiline var description: String = ""
@export var stackable: bool = false

func apply_status(target: Character):
	if target == null:
		return
	
	target.add_status(self)


func on_turn_end(target: Character):
	pass

func on_turn_start(target: Character):
	pass

func on_remove(target: Character):
	pass

@abstract
func get_description(host: Character = null) -> String
