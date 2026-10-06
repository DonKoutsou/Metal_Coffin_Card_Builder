extends CardModuleProperty

class_name CardModuleEnumProperty



@export var option : OptionButton

func SetOptions(ops : PackedStringArray) -> void:
	for g in ops:
		option.add_item(g)

func SetProperty(pName : String, value : Variant) -> void:
	super(pName, value)
	option.select(value)


func _on_option_button_item_selected(index: int) -> void:
	PropertyChanged.emit(propertyName, index)
