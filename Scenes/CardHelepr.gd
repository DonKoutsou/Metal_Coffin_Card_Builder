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
	
	#Also get scripts from mod instead of only base game to cover custom modules
	var modCardModuleDir = Main.dirs.ModDir + "/MetalEngineBase/Cardfight/Card/Card_Modules/"
	
	var DirsToExplore :Array[String] = [modCardModuleDir]
	for g in DirsToExplore:
		var dir = DirAccess.open(g)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					print("Found directory: " + file_name)
					DirsToExplore.append(g + "/" + file_name)
				else:
					print("Found file: " + file_name)
					if (file_name.ends_with(".gd")):
						#Gather data for class
						var clName = get_class_name_from_file(g + "/" + file_name)
						var baseClass = get_extended_class_from_file(g + "/" + file_name)
						var prName = prettify_class_name(clName)
						
						#If the module already exsists in the base pck skipp
						#TODO find a way to override the base ones
						if (!module_list.has(prName)):
							
							var customDic : Dictionary[String, String] = {"base" : baseClass}
							classes[clName] = customDic
							
							#Check if it's a module
							if _inherits_from(clName, "CardModule", classes):
								var sc : GDScript = load(g + "/" + file_name)
								
								if (!allowPassive):
									if (sc.CanBeInPassive()):
										module_list[prName] = sc
								else:
									module_list[prName] = sc
								
				file_name = dir.get_next()

	return module_list

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
