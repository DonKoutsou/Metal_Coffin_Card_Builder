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
		passiveSection.ConfigurePassive(c.Passive)
	
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
		for g in c.OnLeftOnHandModule:
			var modDesc = leftOnHandSection.ConfigureModule(g)
			modDesc.Remove.connect(ModuleRemoved.bind(g))
	

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

func Add_ONPERFORM() -> void:
	if (describedCard.OnPerformModule != null):
		printerr("Card Can Only Have 1 Perform Module")
		return

func Add_ONUSE() -> void:
	pass

func Add_ONDISCARD() -> void:
	pass

func Add_ONLEFTONHAND() -> void:
	pass

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


	
