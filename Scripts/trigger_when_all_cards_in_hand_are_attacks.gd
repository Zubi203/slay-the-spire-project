class_name TriggerWhenAllCardsInHandAreAttacks
extends AttackCardData

var card_manager: CardManager:
	get: return ManagerRegistry.get_manager("card_manager")

func check_cast_condition() -> bool:
	var can_cast: bool = true
	for card in card_manager.card_nodes:
		if not card.card_data.type == CardType.ATTACK:
			can_cast = false
			break
	
	return can_cast
