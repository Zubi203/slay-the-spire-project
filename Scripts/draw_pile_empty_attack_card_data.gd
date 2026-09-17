class_name DrawPileEmptyAttackCardData
extends AttackCardData

var card_manager: CardManager:
	get: return ManagerRegistry.get_manager("card_manager")

func check_cast_condition() -> bool:
	return card_manager.draw_pile.is_empty()
