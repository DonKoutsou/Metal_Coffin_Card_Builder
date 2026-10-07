extends CardModuleProperty

class_name CardModuleResourceProperty

var arr : Array[Resource]
var objType : GDScript

@export var arrayContentParent : Control

@export var boolScene : PackedScene
@export var intScene : PackedScene
@export var floatScene : PackedScene

func _on_add_pressed() -> void:
	var newInstance = objType.new()
	arr.append(newInstance)

		
func PropChanged(pName : String, newValue : Variant) -> void:
	arr[str_to_var(pName)] = newValue
	PropertyChanged.emit(propertyName , arr)		

func HandleProperty(properyName : String, type : Variant.Type) -> CardModuleProperty:
	var moduleDesc : CardModuleProperty
	match (type):
		Variant.Type.TYPE_BOOL:
			moduleDesc = boolScene.instantiate()
		Variant.Type.TYPE_INT:
			moduleDesc = intScene.instantiate()
		Variant.Type.TYPE_FLOAT:
			moduleDesc = floatScene.instantiate()
		Variant.Type.TYPE_ARRAY:
			print("Nested arrays are not supported")
		_:
			print("Could not map nested property {0} of type {1}".format([properyName, type]))
			return
	
	
	return moduleDesc
