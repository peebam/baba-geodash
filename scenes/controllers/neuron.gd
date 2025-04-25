class_name Neuron extends Node

const RANDOM_POSITION_LIMIT := 32.0
const EVOLUTION_POSITION_LIMIT := 8.0

enum DetectorEvolutions {
	Position,
	Reverse,
	Target,
}

enum ConnectorEvolutions {
	Add,
	Operation,
	Position,
	Remove,
}

enum RootEvolutions {
	Add,
	Pass,
	Remove,
}

# Classes

class IDescription:
	func duplicate() -> IDescription:
		return null


	func evolve() -> void:
		pass


	func generate() -> Node:
		return null


	func random() -> void:
		pass


	func to_dictionary() -> Dictionary:
		return {}


class ConnectorDescription extends IDescription:
	var children : Array[IDescription]
	var operation : Connector.Operations
	var position : Vector2
	var root : bool


	func _init(root_ := false) -> void:
		root = root_


	func duplicate() -> IDescription:
		var clone := ConnectorDescription.new()
		for i in children.size():
			clone.children.append(
				children[i].duplicate()
			)
		clone.operation = operation
		clone.position = position
		clone.root = root
		return clone


	func evolve() -> void:
		if root:
			_evolve_root()
		else:
			_evolve_connector()

	func _compute_connector_evolutions() -> Array[ConnectorEvolutions]:
		var evolutions: Array[ConnectorEvolutions] = [
			ConnectorEvolutions.Position,
		]

		if children.size() > 1:
			evolutions.append(ConnectorEvolutions.Operation)

		if children.size() <= 3:
			evolutions.append(ConnectorEvolutions.Add)

		if children.size() > 1:
			evolutions.append(ConnectorEvolutions.Remove)

		return evolutions

	func _evolve_connector() -> void:
		var evolution = _compute_connector_evolutions().pick_random()
		match evolution:
			ConnectorEvolutions.Add:
				var detector := DetectorDescription.new()
				detector.random()
				children.append(detector)
				return
			ConnectorEvolutions.Operation:
				operation = Connector.Operations.AND if operation == Connector.Operations.OR else Connector.Operations.OR
				return
			ConnectorEvolutions.Position:
				position += Vector2(
					randf_range(-EVOLUTION_POSITION_LIMIT, EVOLUTION_POSITION_LIMIT),
					randf_range(-EVOLUTION_POSITION_LIMIT, EVOLUTION_POSITION_LIMIT)
				)
				return
			ConnectorEvolutions.Remove:
				if not children.is_empty():
					children.remove_at(randi() % children.size())
				return


	func _compute_root_evolutions() -> Array[RootEvolutions]:
		var evolutions: Array[RootEvolutions] = [
			RootEvolutions.Pass
		]

		if children.size() <= 3:
			evolutions.append(RootEvolutions.Add)

		if children.size() > 1:
			evolutions.append(RootEvolutions.Remove)

		return evolutions


	func _evolve_root():
		var evolution = _compute_root_evolutions().pick_random()
		match evolution:
			RootEvolutions.Add:
				var connector := ConnectorDescription.new()
				connector.random()
				children.append(connector)
				return
			RootEvolutions.Remove:
				if not children.is_empty():
					children.remove_at(randi() % children.size())
				return

		var descriptions: Array[IDescription] = []
		var stack = children.duplicate()
		while not stack.is_empty():
			var description = stack.pop_front()
			if description is ConnectorDescription:
				stack.append_array(
					description.children.duplicate()
				)
			descriptions.append(description)

		if not descriptions.is_empty():
			var description: IDescription = descriptions.pick_random()
			description.evolve()


	func generate() -> Node:
		var connector := Connector.new_secen()
		connector.operation = operation
		connector.position = position

		for i in children.size():
			connector.add_child(
				children[i].generate()
			)
		return connector


	func random() -> void:
		operation = [
			Connector.Operations.AND,
			Connector.Operations.OR
		].pick_random()

		if not root:
			position = Vector2(
				randf_range(-RANDOM_POSITION_LIMIT, RANDOM_POSITION_LIMIT),
				randf_range(-RANDOM_POSITION_LIMIT, RANDOM_POSITION_LIMIT)
			)

			var detector := DetectorDescription.new()
			detector.random()
			children.append(detector)
			return

		var connector := ConnectorDescription.new(false)
		connector.random()
		children.append(connector)


	func to_dictionary() -> Dictionary:
		return {
			"_type": "connector",
			"children": children.map(func (c): return c.to_dictionary()),
			"operation": operation,
			"position": position,
			"root": root,
		}


class DetectorDescription extends IDescription:
	var position : Vector2
	var reverse : bool
	var target : Detector.Targets


	func duplicate() -> IDescription:
		var clone := DetectorDescription.new()
		clone.position = position
		clone.reverse = reverse
		clone.target = target
		return clone


	func evolve() -> void:
		var evolution = [
			DetectorEvolutions.Position,
			DetectorEvolutions.Reverse,
			DetectorEvolutions.Target,
		].pick_random()

		prints("Detector evolution", evolution)

		match evolution:
			DetectorEvolutions.Position:
				position += Vector2(
					randf_range(-EVOLUTION_POSITION_LIMIT, EVOLUTION_POSITION_LIMIT),
					randf_range(-EVOLUTION_POSITION_LIMIT, EVOLUTION_POSITION_LIMIT)
				)
				return
			DetectorEvolutions.Reverse:
				reverse = not reverse
				return
			DetectorEvolutions.Target:
				target = Detector.Targets.WALL if target == Detector.Targets.PIKE else Detector.Targets.PIKE
				return


	func generate() -> Node:
		var detector := Detector.new_secen()
		detector.position = position
		detector.reverse = reverse
		detector.target = target
		return detector


	func random() -> void:
		reverse = [
			true,
			false
		].pick_random()

		target = [
			Detector.Targets.WALL,
			Detector.Targets.PIKE
		].pick_random()

		position = Vector2(
			randf_range(-RANDOM_POSITION_LIMIT, RANDOM_POSITION_LIMIT),
			randf_range(-RANDOM_POSITION_LIMIT, RANDOM_POSITION_LIMIT)
		)


	func to_dictionary() -> Dictionary:
		return {
			"_type": "dectector",
			"position": position,
			"reverse": reverse,
			"target": target
		}
