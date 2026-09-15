extends DialogueNodeProcessor

static func process(parser: DialogueParser, dict: Dictionary) -> void:
	if dict.operator == 0:
		Inventory.find_and_add_item(dict.item_name, dict.type, dict.quantity)
	else:
		Inventory.find_and_add_item(dict.item_name, dict.type, -dict.quantity)

	parser.proceed(dict.link)
