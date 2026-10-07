extends PanelContainer

class_name CardModuleSection

@export var foldCont : FoldableContainer
@export var contentParent : Control

@export var moduleDescriptorScene : PackedScene
@export var passiveModuleDescriptorScene : PackedScene

@export var boolScene : PackedScene
@export var intScene : PackedScene
@export var enumScene : PackedScene
@export var floatScene : PackedScene

signal Add
signal PropertyChanged()

var SectionName : String = ""
var modAmm : int = 0

func _ready() -> void:
	foldCont.folded = true

func GetContentParent() -> Control:
	return contentParent

func SetSectionName(sectionName : String) -> void:
	SectionName = sectionName
	foldCont.title = sectionName

func UpdateSectionTitle() -> void:
	foldCont.title = SectionName
	if (modAmm > 0):
		foldCont.title += " ({0})".format([modAmm])

func ConfigurePassive(passive : Card_Passive) -> CardModuleDescriptor:
	modAmm += 1
	UpdateSectionTitle()
	
	var moduleContainer : CardPassiveModuleDescriptor = passiveModuleDescriptorScene.instantiate()
	GetContentParent().add_child(moduleContainer)
	moduleContainer.ConfigurePassive(passive)
	moduleContainer.title = passive.get_script().get_global_name()
	moduleContainer.folded = true
	
	moduleContainer.Remove.connect(ModuleRemoved)
	
	moduleContainer.PassivePropertyChanged.connect(OnPropertyChanged.bind(passive))
	
	var props : Array[Dictionary] = get_all_script_variables(passive.Module)
	
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
			Variant.Type.TYPE_FLOAT:
				moduleDesc = floatScene.instantiate()
			_:
				print("Could not map property {0} of type {1}".format([properyName, type]))
				continue

		moduleDesc.SetProperty(properyName, passive.Module.get(properyName))
		moduleContainer.GetModulePropertyParent().add_child(moduleDesc)
		moduleDesc.PropertyChanged.connect(OnPropertyChanged.bind(passive.Module))
	
	return moduleContainer

func ConfigureModule(module : CardModule) -> CardModuleDescriptor:
	if (module == null):
		return
	
	modAmm += 1
	UpdateSectionTitle()
	
	var moduleContainer : CardModuleDescriptor = moduleDescriptorScene.instantiate()
	GetContentParent().add_child(moduleContainer)
	moduleContainer.title = module.get_script().get_global_name()
	moduleContainer.folded = true
	
	moduleContainer.Remove.connect(ModuleRemoved)
	
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
			Variant.Type.TYPE_FLOAT:
				moduleDesc = floatScene.instantiate()
			_:
				print("Could not map property {0} of type {1}".format([properyName, type]))
				continue
		
		moduleDesc.SetProperty(properyName, module.get(properyName))
		moduleContainer.GetModulePropertyParent().add_child(moduleDesc)
		moduleDesc.PropertyChanged.connect(OnPropertyChanged.bind(module))
	
	
	return moduleContainer

func ModuleRemoved() -> void:
	modAmm -= 1
	UpdateSectionTitle()

func OnPropertyChanged(pName : String, newValue : Variant, obj : Object) -> void:
	obj.set(pName, newValue)
	PropertyChanged.emit()

func _on_add_pressed() -> void:
	Add.emit()

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
