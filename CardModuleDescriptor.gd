extends PanelContainer

class_name CardDescriptor

@export var boolScene : PackedScene
@export var intScene : PackedScene
@export var enumScene : PackedScene
@export var floatScene : PackedScene

@export var simpleSectionScene : PackedScene

signal CardUpdated

var describedCard : CardStats

var passiveSection : CardModuleSection
var onPerformSection : CardModuleSection
var onUseSection : CardModuleSection
var onDiscardSection : CardModuleSection
var leftOnHandSection : CardModuleSection

func ConfigureCard(c : CardStats) -> void:
	describedCard = c
	
	print("Showing card {0} of path {1}".format([c.GetCardName(), c.resource_path]))
	for g in get_child(0).get_children():
		g.queue_free()
	
	passiveSection = AddSection("PASSIVE")
	get_child(0).add_child(passiveSection)
	passiveSection.Add.connect(Add_PASSIVE)
	passiveSection.PropertyChanged.connect(OnPropertyChanged)
	
	onPerformSection = AddSection("ON PERFORM")
	get_child(0).add_child(onPerformSection)
	onPerformSection.Add.connect(Add_ONPERFORM)
	onPerformSection.PropertyChanged.connect(OnPropertyChanged)
	
	onUseSection = AddSection("ON USE")
	get_child(0).add_child(onUseSection)
	onUseSection.Add.connect(Add_ONUSE)
	onUseSection.PropertyChanged.connect(OnPropertyChanged)
	
	onDiscardSection = AddSection("ON DISCARD")
	get_child(0).add_child(onDiscardSection)
	onDiscardSection.Add.connect(Add_ONDISCARD)
	onDiscardSection.PropertyChanged.connect(OnPropertyChanged)
	
	leftOnHandSection = AddSection("ON LEFT ON HAND")
	get_child(0).add_child(leftOnHandSection)
	leftOnHandSection.Add.connect(Add_ONLEFTONHAND)
	leftOnHandSection.PropertyChanged.connect(OnPropertyChanged)
	
	if (c.Passive):
		var passiveDesc = passiveSection.ConfigurePassive(c.Passive)
		passiveDesc.Remove.connect(PassiveRemoved.bind(c.Passive))
	
	if (c.OnPerformModule != null):
		var modDesc = onPerformSection.ConfigureModule(c.OnPerformModule)
		modDesc.Remove.connect(ModuleRemoved.bind(c.OnPerformModule))

	for g in c.OnUseModules:
		var modDesc = onUseSection.ConfigureModule(g)
		modDesc.Remove.connect(ModuleRemoved.bind(g))
		
	for g in c.OnDiscardModules:
		var modDesc = onDiscardSection.ConfigureModule(g)
		modDesc.Remove.connect(ModuleRemoved.bind(g))
	
	if (c.OnLeftOnHandModule):
		var modDesc = leftOnHandSection.ConfigureModule(c.OnLeftOnHandModule)
		modDesc.Remove.connect(ModuleRemoved.bind(c.OnLeftOnHandModule))

func PassiveRemoved(passive : Card_Passive) -> void:
	describedCard.Passive = null
	ResaveCard()
	CardUpdated.emit()

func ModuleRemoved(mod : CardModule) -> void:
	if (describedCard.OnPerformModule == mod):
		describedCard.OnPerformModule = null
	else: if (describedCard.OnUseModules.has(mod)):
		describedCard.OnUseModules.erase(mod)
	else: if (describedCard.OnDiscardModules.has(mod)):
		describedCard.OnDiscardModules.erase(mod)
	else: if (describedCard.OnLeftOnHandModule == mod):
		describedCard.OnLeftOnHandModule = null
	ResaveCard()
	CardUpdated.emit()

func Add_PASSIVE() -> void:
	if (describedCard.Passive != null):
		printerr("Card Can Only Have 1 Passive")
		return
	
	var newPassive = await SelectPassive()
	
	var newModule = await SelectModule(false)
	newPassive.Module = newModule
	describedCard.Passive = newPassive
	
	var passiveDesc = passiveSection.ConfigurePassive(newPassive)
	passiveDesc.Remove.connect(PassiveRemoved.bind(newPassive))
	OnPropertyChanged()
	

func Add_ONPERFORM() -> void:
	if (describedCard.OnPerformModule != null):
		printerr("Card Can Only Have 1 Perform Module")
		return
	
	var newModule = await SelectModule()
	describedCard.OnPerformModule = newModule
	newModule.resource_path = describedCard.resource_path
	
	
	var modDesc = onPerformSection.ConfigureModule(newModule)
	modDesc.Remove.connect(ModuleRemoved.bind(newModule))
	OnPropertyChanged()

func Add_ONUSE() -> void:
	var newModule = await SelectModule()
	describedCard.OnUseModules.append(newModule)
	newModule.resource_path = describedCard.resource_path
	
	var modDesc = onUseSection.ConfigureModule(newModule)
	modDesc.Remove.connect(ModuleRemoved.bind(newModule))
	OnPropertyChanged()

func Add_ONDISCARD() -> void:
	var newModule = await SelectModule()
	describedCard.OnDiscardModules.append(newModule)
	newModule.resource_path = describedCard.resource_path
	
	var modDesc = onDiscardSection.ConfigureModule(newModule)
	modDesc.Remove.connect(ModuleRemoved.bind(newModule))
	OnPropertyChanged()

func Add_ONLEFTONHAND() -> void:
	if (describedCard.OnLeftOnHandModule != null):
		printerr("Card Can Only Have 1 Perform Module")
		return
		
	var newModule = await SelectModule()
	describedCard.OnLeftOnHandModule = newModule
	newModule.resource_path = describedCard.resource_path
	
	var modDesc = leftOnHandSection.ConfigureModule(newModule)
	modDesc.Remove.connect(ModuleRemoved.bind(newModule))
	OnPropertyChanged()

func SelectPassive() -> Card_Passive:
	var passiveList = GetPassiveList()
	
	var opt : OptionButton = OptionButton.new()
	for g in passiveList:
		opt.add_item(g)
	
	add_child(opt)
	opt.show_popup()
	var selected = await opt.item_selected
	opt.queue_free()
	
	var selectedName = passiveList.keys()[selected]
	
	return passiveList[selectedName].new()

func SelectModule(allowPassive : bool = true) -> CardModule:
	var moduleList = GetModuleList(allowPassive)
	
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
	

func OnPropertyChanged() -> void:
	ResaveCard()
	CardUpdated.emit()

func ResaveCard() -> void:
	ResourceSaver.save(describedCard, describedCard.resource_path)
	print("Card Saved At {0}".format([describedCard.resource_path]))

func AddSection(sectionName : String) -> CardModuleSection:
	var section : CardModuleSection = simpleSectionScene.instantiate()
	section.SetSectionName(sectionName)
	return section

func AddPassiveSection(ReceiverType : Card_Passive.ReceiverType, Target : Card_Passive.TargetType) -> Control:
	var container : VBoxContainer = VBoxContainer.new()
	var pLabel : Label = Label.new()
	pLabel.text = "PASSIVE"
	pLabel.add_theme_font_size_override("font_size", 22)
	pLabel.add_theme_color_override("font_color", Color(1,1,1,1))
	container.add_child(pLabel)
	var hcontainer : HBoxContainer = HBoxContainer.new()
	container.add_child(hcontainer)
	var l : Label = Label.new()
	l.text = "RECEIVER : " + Card_Passive.ReceiverType.keys()[ReceiverType]
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color(1,1,1,1))
	hcontainer.add_child(l)
	var l2 : Label = Label.new()
	l2.text = "TARGET : " + Card_Passive.TargetType.keys()[Target]
	l2.add_theme_font_size_override("font_size", 22)
	l2.add_theme_color_override("font_color", Color(1,1,1,1))
	l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hcontainer.add_child(l2)
	return container

func GetModuleList(allowPassive : bool) -> Dictionary[String, GDScript]:
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

func GetPassiveList() -> Dictionary[String, GDScript]:
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


func _inherits_from(clName: String,target_class: String,classes: Dictionary[String, Dictionary]) -> bool:
	var current: String = clName

	while classes.has(current):
		var base: String = classes[current]["base"]

		if base == target_class:
			return true

		current = base

	return false

func prettify_class_name(clName: String) -> String:
	var regex := RegEx.new()
	regex.compile("(?<!^)([A-Z])")
	return regex.sub(clName, " $1", true)
