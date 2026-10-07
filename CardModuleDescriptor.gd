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
	passiveSection.Added.connect(Add_PASSIVE)
	passiveSection.Removed.connect(Remove_PASSIVE)
	passiveSection.PropertyChanged.connect(OnPropertyChanged)
	passiveSection.MaxAmm = 1
	passiveSection.SectionT = CardModuleSection.SectionType.PASSIVE
	
	onPerformSection = AddSection("ON PERFORM")
	get_child(0).add_child(onPerformSection)
	onPerformSection.Added.connect(Add_ONPERFORM)
	onPerformSection.Removed.connect(Remove_ONPERFORM)
	onPerformSection.PropertyChanged.connect(OnPropertyChanged)
	onPerformSection.MaxAmm = 1
	
	onUseSection = AddSection("ON USE")
	get_child(0).add_child(onUseSection)
	onUseSection.Added.connect(Add_ONUSE)
	onUseSection.Removed.connect(Remove_ONUSE)
	onUseSection.PropertyChanged.connect(OnPropertyChanged)
	onUseSection.MaxAmm = 10
	
	onDiscardSection = AddSection("ON DISCARD")
	get_child(0).add_child(onDiscardSection)
	onDiscardSection.Added.connect(Add_ONDISCARD)
	onDiscardSection.Removed.connect(Remove_ONDISCARD)
	onDiscardSection.PropertyChanged.connect(OnPropertyChanged)
	onDiscardSection.MaxAmm = 10
	
	leftOnHandSection = AddSection("ON LEFT ON HAND")
	get_child(0).add_child(leftOnHandSection)
	leftOnHandSection.Added.connect(Add_ONLEFTONHAND)
	leftOnHandSection.Removed.connect(Remove_ONLEFTONHAND)
	leftOnHandSection.PropertyChanged.connect(OnPropertyChanged)
	leftOnHandSection.MaxAmm = 1
	
	if (c.Passive):
		var passiveDesc = passiveSection.ConfigurePassive(c.Passive)
	
	if (c.OnPerformModule != null):
		onPerformSection.ConfigureModule(c.OnPerformModule)

	for g in c.OnUseModules:
		onUseSection.ConfigureModule(g)
		
	for g in c.OnDiscardModules:
		onDiscardSection.ConfigureModule(g)
	
	if (c.OnLeftOnHandModule):
		leftOnHandSection.ConfigureModule(c.OnLeftOnHandModule)

func Add_PASSIVE(newPassive : Card_Passive) -> void:
	describedCard.Passive = newPassive
	OnPropertyChanged()

func Remove_PASSIVE(removedPassive : Card_Passive) -> void:
	describedCard.Passive = null
	OnPropertyChanged()

func Add_ONPERFORM(newModule : CardModule) -> void:
	describedCard.OnPerformModule = newModule
	OnPropertyChanged()

func Remove_ONPERFORM(removedModule : CardModule) -> void:
	describedCard.OnPerformModule = null
	OnPropertyChanged()

func Add_ONUSE(newModule : CardModule) -> void:
	describedCard.OnUseModules.append(newModule)
	OnPropertyChanged()

func Remove_ONUSE(removedModule : CardModule) -> void:
	describedCard.OnUseModules.erase(removedModule)
	OnPropertyChanged()

func Add_ONDISCARD(newModule : CardModule) -> void:
	describedCard.OnDiscardModules.append(newModule)
	OnPropertyChanged()

func Remove_ONDISCARD(removedModule : CardModule) -> void:
	describedCard.OnDiscardModules.erase(removedModule)
	OnPropertyChanged()

func Add_ONLEFTONHAND(newModule : CardModule) -> void:
	describedCard.OnLeftOnHandModule = newModule
	OnPropertyChanged()

func Remove_ONLEFTONHAND(removedModule : CardModule) -> void:
	describedCard.OnLeftOnHandModule = null
	OnPropertyChanged()

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
