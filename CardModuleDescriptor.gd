extends PanelContainer

class_name CardModuleDescriptor

@export var boolScene : PackedScene
@export var intScene : PackedScene

func ConfigureModule(module : CardModule) -> void:
	for g in get_child(0).get_children():
		g.queue_free()
	
	if (module == null):
		return
	
	var props : Array[Dictionary] = get_all_script_variables(module)
	
	for prop : Dictionary in props :
		var properyName : String = prop["name"]
		var type : Variant.Type = prop["type"]
		var hint : PropertyHint = prop["hint"]
		var usage : PropertyUsageFlags = prop["usage"]
		
		if (!usage & PROPERTY_USAGE_EDITOR):
			continue
		
		var moduleDesc : CardModuleProperty
		match (type):
			Variant.Type.TYPE_BOOL:
				moduleDesc = boolScene.instantiate()
			Variant.Type.TYPE_INT:
				if (hint == PropertyHint.PROPERTY_HINT_ENUM):
					continue
				else:
					moduleDesc = intScene.instantiate()
			_:
				continue

		moduleDesc.SetProperty(properyName, module.get(properyName))
		get_child(0).add_child(moduleDesc)

func get_exported_enum_data(prop_dict: Dictionary) -> Dictionary:
	var enum_data = {}
	
	if prop_dict.hint == PROPERTY_HINT_ENUM:
		# "IDLE,RUNNING,DEAD" -> ["IDLE", "RUNNING", "DEAD"]
		var keys = prop_dict.hint_string.split(",")
		
		for i in keys.size():
			enum_data[keys[i]] = i  # Maps {"IDLE": 0, "RUNNING": 1...}
			
	return enum_data

func get_all_script_variables(res : Resource) -> Array[Dictionary]:
	return res.get_property_list().filter(func(prop):
		return prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
	)
