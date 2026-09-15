extends Resource
class_name DialogueNodeProcessor

static func process(parser: DialogueParser, dict: Dictionary): pass


static func process_condition(parser: DialogueParser, dict: Dictionary):
	var result = parser.check_condition(dict['condition'])
	parser.proceed(dict[str(result).to_lower()])


static func process_fork(parser: DialogueParser, dict: Dictionary):
	var result = dict.default
	var forks = dict.forks
	# index traversal to ensure they're checked in order
	for i in range(0, forks.size()):
		if parser.check_condition(forks[i].condition):
			result = forks[i].link
			break
	parser.proceed(result)


static func process_set(parser: DialogueParser, dict: Dictionary):
	var variables := parser.variables
	if not variables.has(dict.variable):
		printerr('Variable ', dict.variable, ' not found in variables list')
		parser.proceed(dict.link)
		return
	
	var type = typeof(variables[dict.variable])
	var value = dict.value
	if value.count("{{"):
		value = parser.parse_variables(value)
	
	var operator = dict.type
	
	# set datatype of value
	match typeof(variables[dict.variable]):
		TYPE_STRING:
			value = str(value)

			# check for invalid operators
			if operator > 2:
				printerr('Invalid operator for type: String')
				parser.proceed(dict.link)
				return
		TYPE_INT:
			value = int(value)
		TYPE_FLOAT:
			value = float(value)
		TYPE_BOOL:
			value = (value == 'true') if value is String else bool(value)

			# check for invalid operators
			if operator > 0:
				printerr('Invalid operator for type: Boolean')
				parser.proceed(dict.link)
				return

	# perform operation
	match operator:
		0:
			variables[dict.variable] = value
		1:
			variables[dict.variable] += value
		2:
			variables[dict.variable] -= value
		3:
			variables[dict.variable] *= value
		4:
			variables[dict.variable] /= value
	
	parser.variable_changed.emit(dict.variable, variables[dict.variable])
	parser.proceed(dict.link)


static func process_signal(parser: DialogueParser, dict: Dictionary):
	var key: Variant = dict.signal_value.value
	if dict.signal_value.use_enum:
		key = StoryManager.get_signal_from_key(dict.signal_value.value)

	parser.dialogue_signal.emit(key)
	if dict.auto_proceed:
		parser.proceed(dict.link)
	else:
		parser.start_event(dict.link)


static func process_start(parser: DialogueParser, dict: Dictionary):
	parser.proceed(dict.link)
