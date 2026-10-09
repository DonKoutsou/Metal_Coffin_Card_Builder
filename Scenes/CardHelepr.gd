extends RefCounted

class_name CardHelper

static func GetModuleList(allowPassive : bool) -> Dictionary[String, GDScript]:
	var module_list: Dictionary[String, GDScript] = {}
	
	var global_class_list: Array[Dictionary] = Main.globalClassList
	
	# class name -> class info
	var classes: Dictionary[String, Dictionary] = {}

	for info: Dictionary in global_class_list:
		classes[info["class"]] = info

	for info: Dictionary in global_class_list:
		var clName: String = info["class"]

		if _inherits_from(clName, "CardModule", classes):
			var class_path: String = info["path"]
			var prName = prettify_class_name(clName)
			var sc : GDScript = ResourceLoader.load(class_path)
			
			if (!allowPassive):
				if (sc.CanBeInPassive()):
					module_list[prName] = sc
			else:
				module_list[prName] = sc
				
	return module_list

static func LoadModScripts() -> void:
	var modCardModuleDir = Main.dirs.ModDir
	
	var existingClasses: Dictionary[String, String]
	
	var global_class_list: Array[Dictionary] = Main.globalClassList
	
	# class name -> class info
	var classes: Dictionary[String, Dictionary] = {}

	for info: Dictionary in global_class_list:
		classes[info["class"]] = info

	for info: Dictionary in global_class_list:
		var clName: String = info["class"]

		if _inherits_from(clName, "CardModule", classes) or _inherits_from(clName, "Card_Passive", classes):
			var class_path: String = info["path"]
			existingClasses[clName] = class_path
	
	var DirsToExplore :Array[String] = [modCardModuleDir]
	for g in DirsToExplore:
		var dir = DirAccess.open(g)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					#print("Found directory: " + file_name)
					DirsToExplore.append(g + "/" + file_name)
				else:
					#print("Found file: " + file_name)
					if (file_name.ends_with(".gd")):
						#Gather data for class
						var clName = get_class_name_from_file(g + "/" + file_name)
						var baseClass = get_extended_class_from_file(g + "/" + file_name)

						if (existingClasses.has(clName)):
							var originalScriptPath = existingClasses[clName]
							var err = replace_class_source(originalScriptPath, g + "/" + file_name)
							if (err != OK):
								push_error("Replacing script returned with error {0}".format([err]))
						else:
							var customDic : Dictionary[String, String] = {
								"base" : baseClass,
								"class" : clName,
								"path" : g + "/" + file_name
								}
							
							Main.globalClassList.append(customDic)
								
				file_name = dir.get_next()

#----------------------------------------------------------------------
##Passes both files through a hash function and checks the resault
static func _files_are_identical(file_a: String,file_b: String) -> bool:

	var hash_a := FileAccess.get_sha256(file_a)
	var hash_b := FileAccess.get_sha256(file_b)

	return hash_a == hash_b


#----------------------------------------------------------------------
static func replace_class_source(original_path: String ,external_path: String) -> Error:
	var original : Script = ResourceLoader.load(original_path)
	if original == null:
		return ERR_CANT_OPEN

	var file := FileAccess.open(external_path, FileAccess.READ)
	if file == null:
		return ERR_CANT_OPEN

	var new_source = file.get_as_text()
	file.close()
	
	var originalSource : String = original.source_code
	var dif : bool = _files_are_identical(originalSource, new_source)
	
	if (dif):
		original.source_code = new_source
		var error = original.reload(true)
		print("Script Replaced {0}".format([original_path.get_file()]))
		return error
			
	return ERR_ALREADY_EXISTS

#----------------------------------------------------------------------
static func get_function_return_from_file(path: String, function_name: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null

	var inside_function := false
	var indent_level := -1

	while not file.eof_reached():
		var line := file.get_line()
		var trimmed := line.strip_edges()

		if not inside_function:
			if trimmed.begins_with("func " + function_name + "("):
				inside_function = true
				indent_level = line.length() - line.lstrip(" \t").length()
			continue

		# Stop when another function or same-level declaration begins.
		var current_indent := line.length() - line.lstrip(" \t").length()
		if trimmed.begins_with("func ") and current_indent <= indent_level:
			break

		if trimmed.begins_with("return "):
			var value_text := trimmed.trim_prefix("return ").strip_edges()

			if value_text.is_valid_int():
				return value_text.to_int()
			if value_text.is_valid_float():
				return value_text.to_float()
			if value_text == "true":
				return true
			if value_text == "false":
				return false
			if value_text == "null":
				return null
			if value_text.begins_with('"') and value_text.ends_with('"'):
				return value_text.substr(1, value_text.length() - 2)

			return value_text

	return null

static func get_variable_from_file(path: String, variable_name: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null

	var prefix := "var " + variable_name
	var static_prefix := "static var " + variable_name

	while not file.eof_reached():
		var line := file.get_line().strip_edges()

		if line.begins_with(prefix) or line.begins_with(static_prefix):
			var parts := line.split("=", true, 1)
			if parts.size() < 2:
				return null

			var value_text := parts[1].strip_edges()

			# Handle simple literal values.
			if value_text.is_valid_int():
				return value_text.to_int()
			if value_text.is_valid_float():
				return value_text.to_float()
			if value_text == "true":
				return true
			if value_text == "false":
				return false
			if value_text == "null":
				return null
			if value_text.begins_with('"') and value_text.ends_with('"'):
				return value_text.substr(1, value_text.length() - 2)

			return value_text

	return null

static func get_class_name_from_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("class_name "):
			return line.trim_prefix("class_name ").split(" ")[0]

	return ""

static func get_extended_class_from_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("extends "):
			return line.trim_prefix("extends ").split(" ")[0]

	return ""

static func GetPassiveList() -> Dictionary[String, GDScript]:
	var module_list: Dictionary[String, GDScript] = {}
	var global_class_list: Array[Dictionary] = Main.globalClassList

	# class name -> class info
	var classes: Dictionary[String, Dictionary] = {}

	for info: Dictionary in global_class_list:
		classes[info["class"]] = info

	for info: Dictionary in global_class_list:
		var clName: String = info["class"]

		if _inherits_from(clName, "Card_Passive", classes):
			var class_path: String = info["path"]
			var prName = prettify_class_name(clName)
			module_list[prName] = ResourceLoader.load(class_path)

	return module_list

static func get_all_script_variables(res : Resource) -> Array[Dictionary]:
	return res.get_property_list().filter(func(prop):
		return prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
	)

static func _inherits_from(clName: String,target_class: String,classes: Dictionary[String, Dictionary]) -> bool:
	var current: String = clName

	while classes.has(current):
		var base: String = classes[current]["base"]

		if base == target_class:
			return true

		current = base

	return false

static func prettify_class_name(clName: String) -> String:
	var regex := RegEx.new()
	regex.compile("(?<!^)([A-Z])")
	return regex.sub(clName, " $1", true)

static func get_exported_enum_data(prop_dict: Dictionary) -> PackedStringArray:
	var enum_data : PackedStringArray = []
	
	if prop_dict.hint == PROPERTY_HINT_ENUM:
		var keys = prop_dict.hint_string.split(",")
		
		for i in keys.size():
			enum_data.append(keys[i])
			
	return enum_data
