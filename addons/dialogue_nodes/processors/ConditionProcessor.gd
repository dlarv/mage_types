extends DialogueNodeProcessor

static func process(parser: DialogueParser, dict: Dictionary):
	var result = parser.check_condition(dict['condition'])
	parser.proceed(dict[str(result).to_lower()])
