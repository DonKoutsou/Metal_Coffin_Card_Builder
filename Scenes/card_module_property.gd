extends PanelContainer

class_name CardModuleProperty

@export var nameLabel : Label

var propertyName : String

func SetProperty(pName : String, _value : Variant) -> void:
	propertyName = pName
	nameLabel.text = pName
