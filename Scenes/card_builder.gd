extends PanelContainer

class_name CardBuilder

@export var Menu : PopupMenu
@export var cardShowcasee : Card
@export var cardModuleDesc : CardModuleDescriptor
@export var nameEdit : LineEdit

var cards : Array[CardStats]

var startingDir : String

func _ready() -> void:
	cardShowcasee.SetRealistic()
	UpdateDilogues()

func SetCard(c : CardStats) -> void:
	cardShowcasee.SetCardStats(c)
	cardModuleDesc.ConfigureCard(c)
	nameEdit.text = c.GetCardName()

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
						var crd = load(g + "/" + file_name)
						if (crd is CardStats):
							cards.append(crd)
							Menu.add_item(crd.GetCardName())
				
				file_name = dir.get_next()
	SetCard(cards[0])


func _on_popup_menu_index_pressed(index: int) -> void:
	SetCard(cards[index])
