extends RefCounted

class_name CardHelper

static func GetModuleList(allowPassive : bool) -> Dictionary[String, GDScript]:
	var module_list: Dictionary[String, GDScript] = {}
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()

	# class name -> class info
	var classes: Dictionary[String, Dictionary] = {}

	for info: Dictionary in global_class_list:
		classes[info["class"]] = info

	for info: Dictionary in global_class_list:
		var clName: String = info["class"]

		if _inherits_from(clName, "CardModule", classes):
			var class_path: String = info["path"]
			var prName = prettify_class_name(clName)
			var sc : GDScript = load(class_path)
			
			if (!allowPassive):
				if (sc.CanBeInPassive()):
					module_list[prName] = sc
			else:
				module_list[prName] = sc

	return module_list

static func GetPassiveList() -> Dictionary[String, GDScript]:
	var module_list: Dictionary[String, GDScript] = {}
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()

	# class name -> class info
	var classes: Dictionary[String, Dictionary] = {}

	for info: Dictionary in global_class_list:
		classes[info["class"]] = info

	for info: Dictionary in global_class_list:
		var clName: String = info["class"]

		if _inherits_from(clName, "Card_Passive", classes):
			var class_path: String = info["path"]
			var prName = prettify_class_name(clName)
			module_list[prName] = load(class_path)

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
