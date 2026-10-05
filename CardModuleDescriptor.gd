extends PanelContainer

class_name CardModuleDescriptor

@export var boolScene : PackedScene
@export var intScene : PackedScene
@export var enumScene : PackedScene

func ConfigureCard(c : CardStats) -> void:
	for g in get_child(0).get_children():
		g.queue_free()
		
	ConfigureModule(c.OnPerformModule)
	for g in c.OnUseModules:
		ConfigureModule(g)

func ConfigureModule(module : CardModule) -> void:
	if (module == null):
		return
	
	var container : VBoxContainer = VBoxContainer.new()
	get_child(0).add_child(container)
	var l : Label = Label.new()
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.text = module.get_script().get_global_name()
	container.add_child(l)
	var grid : GridContainer = GridContainer.new()
	grid.columns = 2
	container.add_child(grid)
	
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
					var enumData = get_exported_enum_data(prop)
					var enumDesc : CardModuleEnumProperty = enumScene.instantiate()
					enumDesc.SetOptions(enumData)
					moduleDesc = enumDesc
				else:
					moduleDesc = intScene.instantiate()
			_:
				continue

		moduleDesc.SetProperty(properyName, module.get(properyName))
		grid.add_child(moduleDesc)

func get_exported_enum_data(prop_dict: Dictionary) -> PackedStringArray:
	var enum_data : PackedStringArray = []
	
	if prop_dict.hint == PROPERTY_HINT_ENUM:
		var keys = prop_dict.hint_string.split(",")
		
		for i in keys.size():
			enum_data.append(keys[i])
			
	return enum_data

func get_all_script_variables(res : Resource) -> Array[Dictionary]:
	return res.get_property_list().filter(func(prop):
		return prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
	)
