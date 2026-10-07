extends CardModuleProperty

class_name CardModuleArrayProperty

var arr : Array
var arrType

@export var arrayContentParent : Control

@export var boolScene : PackedScene
@export var intScene : PackedScene
@export var floatScene : PackedScene

func _on_add_pressed() -> void:
	if (arrType is GDScript):
		var newInstance = arrType.new()
		arr.append(newInstance)
	
	else: match typeof(arrType):
		TYPE_INT:
			arr.append(0)
			var prop = HandleProperty(var_to_str(arr.size()), Variant.Type.TYPE_INT)
			prop.SetProperty(var_to_str(arr.size()), 0)
			prop.PropertyChanged.connect(PropChanged)
		TYPE_FLOAT:
			arr.append(0.0)
			var prop = HandleProperty(var_to_str(arr.size()), Variant.Type.TYPE_FLOAT)
			prop.SetProperty(var_to_str(arr.size()), 0.0)
			prop.PropertyChanged.connect(PropChanged)
		TYPE_BOOL:
			arr.append(false)
			var prop = HandleProperty(var_to_str(arr.size()), Variant.Type.TYPE_BOOL)
			prop.SetProperty(var_to_str(arr.size()), false)
			prop.PropertyChanged.connect(PropChanged)
		#TYPE_STRING:
			#arr.append("")
			#HandleProperty("", Variant.Type.TYPE_STRING)
		
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
