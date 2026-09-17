class_name DoubleStatusCard
extends StatusCard

func cast (data : CastData):
	if data.caster == null or data.opponent == null:
		return
	
	if damage > 0:
		data.caster.attack(data.opponent, damage)
	if block > 0:
		data.caster.block(block)
	if heal > 0:
		data.caster.heal(heal)
	
	await data.caster.get_tree().create_timer(0.2).timeout
	
	for status_to_double in debuffs_to_apply:
		var status_count: int = 0
		for status in data.opponent.status_effects:
			if status.status_data.name == status_to_double.name:
				status_count += 1
		for i in status_count:
			status_to_double.apply_status(data.opponent)
	
	for status_to_double in buffs_to_apply:
		var status_count: int = 0
		for status in data.caster.status_effects:
			if status.status_data.name == status_to_double.name:
				status_count += 1
		for i in status_count:
			status_to_double.apply_status(data.caster)

func get_description(data: CastData) -> String:
	var description: String = ""
	if damage > 0:
		description += "Deal " + str(damage) + " damage\n" 
	if block > 0:
		description += "Gain " + str(block) + " block\n" 
	if heal > 0:
		description += "Heal " + str(heal) + " health\n" 
	
	for status in debuffs_to_apply:
		description += "Double the target's " + status.name + "."
	for status in buffs_to_apply:
		description += "Double your " + status.name + "."
	return description
