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

signal Added(new)
signal Removed(removed)
signal PropertyChanged()

var SectionName : String = ""
var SectionT : SectionType
var modAmm : int = 0
var MaxAmm : int = 0

enum SectionType {
	MODULE,
	PASSIVE
}

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

#-------------------------------------------------------------------
func ConfigurePassive(passive : Card_Passive) -> CardModuleDescriptor:
	modAmm += 1
	UpdateSectionTitle()
	
	var moduleContainer : CardPassiveModuleDescriptor = passiveModuleDescriptorScene.instantiate()
	GetContentParent().add_child(moduleContainer)
	moduleContainer.ConfigurePassive(passive)
	moduleContainer.title = passive.get_script().get_global_name()
	moduleContainer.folded = true
	
	moduleContainer.Remove.connect(PassiveRemoved.bind(passive))
	
	moduleContainer.PassivePropertyChanged.connect(OnPropertyChanged.bind(passive))
	
	var props : Array[Dictionary] = CardHelper.get_all_script_variables(passive.Module)
	
	for prop : Dictionary in props :
		var moduleDesc = HandleProperty(prop, passive.Module)
		if (moduleDesc):
			moduleContainer.GetModulePropertyParent().add_child(moduleDesc)
	
	return moduleContainer

#-------------------------------------------------------------------
func ConfigureModule(module : CardModule) -> CardModuleDescriptor:
	if (module == null):
		return
	
	modAmm += 1
	UpdateSectionTitle()
	
	var moduleContainer : CardModuleDescriptor = moduleDescriptorScene.instantiate()
	GetContentParent().add_child(moduleContainer)
	moduleContainer.title = module.get_script().get_global_name()
	moduleContainer.folded = true
	
	moduleContainer.Remove.connect(ModuleRemoved.bind(module))
	
	var props : Array[Dictionary] = CardHelper.get_all_script_variables(module)
	
	for prop : Dictionary in props :
		var moduleDesc = HandleProperty(prop, module)
		if (moduleDesc):
			moduleContainer.GetModulePropertyParent().add_child(moduleDesc)

	return moduleContainer

#-------------------------------------------------------------------
func HandleProperty(prop : Dictionary, module : CardModule) -> Control:
	var properyName : String = prop["name"]
	var type : Variant.Type = prop["type"]
	var hint : PropertyHint = prop["hint"]
	var hintString : String = prop["hint_string"]
	var usage : PropertyUsageFlags = prop["usage"]
		
	var moduleDesc : CardModuleProperty
	match (type):
		Variant.Type.TYPE_BOOL:
			moduleDesc = boolScene.instantiate()
		Variant.Type.TYPE_INT:
			if (hint == PropertyHint.PROPERTY_HINT_ENUM):
				var enumData = CardHelper.get_exported_enum_data(prop)
				var enumDesc : CardModuleEnumProperty = enumScene.instantiate()
				enumDesc.SetOptions(enumData)
				moduleDesc = enumDesc
			else:
				moduleDesc = intScene.instantiate()
		Variant.Type.TYPE_FLOAT:
			moduleDesc = floatScene.instantiate()
		Variant.Type.TYPE_ARRAY:
			if (hintString.contains("CardModule")):
				var newSect : CardModuleSection = load(scene_file_path).instantiate()
				newSect.SetSectionName(properyName)
				
				var moduleArr : Array[CardModule] = module.get(properyName)
				
				newSect.Added.connect(ModuleAddedInArray.bind(moduleArr))
				newSect.Removed.connect(ModuleRemovedFromArray.bind(moduleArr))
				newSect.PropertyChanged.connect(ModulePropertyChanged)
				
				for g in moduleArr:
					newSect.ConfigureModule(g)
				newSect.custom_minimum_size = Vector2(size.x - 50, 0)
				newSect.MaxAmm = 10
				return newSect
			else:
				printerr("Array " + hintString)
			return
		_:
			printerr("Could not map property {0} of type {1}".format([properyName, type]))
			return
	
	moduleDesc.SetProperty(properyName, module.get(properyName))
	moduleDesc.PropertyChanged.connect(OnPropertyChanged.bind(module))
	return moduleDesc

func ModuleAddedInArray(mod : CardModule, arr : Array[CardModule]) -> void:
	arr.append(mod)
	PropertyChanged.emit()

func ModuleRemovedFromArray(mod : CardModule, arr : Array[CardModule]) -> void:
	arr.erase(mod)
	PropertyChanged.emit()

func ModulePropertyChanged() -> void:
	PropertyChanged.emit()

#-------------------------------------------------------------------
func AddModule() -> CardModule:
	if (modAmm == MaxAmm):
		print("Cant add more modules in this section")
		return
		
	var newModule = await SelectModule()
	
	var modDesc = ConfigureModule(newModule)
	return newModule

func AddPassive() -> Card_Passive:
	if (modAmm == MaxAmm):
		print("Cant add more modules in this section")
		return
		
	var newP = await SelectPassive()
	
	var newModule = await SelectModule(false)
	newP.Module = newModule
	
	var modDesc = ConfigurePassive(newP)
	return newP

func SelectPassive() -> Card_Passive:
	var passiveList = CardHelper.GetPassiveList()
	
	var opt : OptionButton = OptionButton.new()
	for g in passiveList:
		opt.add_item(g)
	
	add_child(opt)
	opt.show_popup()
	var selected = await opt.item_selected
	opt.queue_free()
	
	var selectedName = passiveList.keys()[selected]
	
	return passiveList[selectedName].new()

#-------------------------------------------------------------------
func SelectModule(allowPassive : bool = true) -> CardModule:
	var moduleList = CardHelper.GetModuleList(allowPassive)
	
	var opt : OptionButton = OptionButton.new()
	for g in moduleList:
		opt.add_item(g)
	
	add_child(opt)
	opt.show_popup()
	var selected = await opt.item_selected
	opt.queue_free()
	
	var selectedName = moduleList.keys()[selected]
	
	var script : GDScript = moduleList[selectedName]
	var moduleInstance = moduleList[selectedName].new()
	var uid = ResourceUID.path_to_uid(script.resource_path)
	moduleInstance.set_meta("_custom_type_script", uid)
	return moduleInstance

func ModuleRemoved(removedModule : CardModule) -> void:
	Removed.emit(removedModule)
	modAmm -= 1
	UpdateSectionTitle()

func PassiveRemoved(removedPassive : Card_Passive) -> void:
	Removed.emit(removedPassive)
	modAmm -= 1
	UpdateSectionTitle()

func OnPropertyChanged(pName : String, newValue : Variant, obj : Object) -> void:
	obj.set(pName, newValue)
	PropertyChanged.emit()

func _on_add_pressed() -> void:
	if (SectionT == SectionType.MODULE):
		var newMod = await AddModule()
		Added.emit(newMod)
	else: if (SectionT == SectionType.PASSIVE):
		var newPassive = await AddPassive()
		Added.emit(newPassive)
