extends PanelContainer

class_name CardModuleProperty

@export var nameLabel : Label

signal PropertyChanged(pName : String, newValue : Variant)

var propertyName : String

func SetMax(newMax : Variant) -> void:
	pass

func SetProperty(pName : String, _value : Variant) -> void:
	propertyName = pName
	nameLabel.text = CardHelper.prettify_class_name(pName)
