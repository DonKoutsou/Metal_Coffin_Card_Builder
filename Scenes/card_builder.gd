extends PanelContainer

class_name CardBuilder

@export var Menu : PopupMenu
@export var cardShowcasee : Card
@export var cardDesc : CardDescriptor
@export var nameEdit : LineEdit
@export var costBox : SpinBox
@export var texturePicker : ResourcePicker

var cards : Array[CardStats]
var currentCard : int = 0

var startingDir : String

func _ready() -> void:
	UpdateDilogues()

func SetCard(c : CardStats) -> void:
	cardShowcasee.SetCardStats(c)
	
	nameEdit.text = c.GetCardName()
	costBox.value = c.GetCost()
	cardShowcasee.SetRealistic()
	
	var path : String = c.txFile
	if (path.contains("uid")):
		path = ResourceUID.ensure_path(c.txFile)

	texturePicker.SetFile(path)

#--------------------------------------------------------
##Checks happening directory and pulls all of them out
func UpdateDilogues() -> void:
	Menu.clear()
	var DirsToExplore :Array[String] = [startingDir + "/Resources/Cards/"]
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
					if (file_name.ends_with(".tres")):
						var crd = ResourceLoader.load(g + "/" + file_name)
						if (crd is CardStats):
							cards.append(crd)
							Menu.add_item(crd.GetCardName())
				
				file_name = dir.get_next()
	SetCard(cards[currentCard])
	cardDesc.ConfigureCard(cards[currentCard])


func _on_popup_menu_index_pressed(index: int) -> void:
	currentCard = index
	SetCard(cards[index])
	cardDesc.ConfigureCard(cards[index])


func _on_panel_container_3_card_updated() -> void:
	SetCard(cards[currentCard])

func ResaveCard() -> void:
	ResourceSaver.save(cards[currentCard], cards[currentCard].resource_path)
	print("Card Saved At {0}".format([cards[currentCard].resource_path]))


func _on_line_edit_text_changed(new_text: String) -> void:
	cards[currentCard].CardName = new_text
	SetCard(cards[currentCard])
	ResaveCard()


func _on_cost_value_changed(value: float) -> void:
	cards[currentCard].Energy = value
	SetCard(cards[currentCard])
	ResaveCard()
