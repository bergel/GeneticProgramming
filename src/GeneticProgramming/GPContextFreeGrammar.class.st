Class {
	#name : #GPContextFreeGrammar,
	#superclass : #Object,
	#instVars : [
		'rules',
		'random',
		'values'
	],
	#category : #'GeneticProgramming-Interpreter'
}

{ #category : #adding }
GPContextFreeGrammar >> addNode: node [	
	rules
		at: node type
		ifPresent: [ :col | col add: node ]
		ifAbsentPut: [ 
			OrderedCollection new
				add: node;
				yourself ] 
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: key with: sequence [
	self addNode: (self createNode: key with: sequence)
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: key withLeaf: nodeValues [

	self addNode: (self createNode: key with: #()).
	values at: key put: nodeValues asOrderedCollection 
]

{ #category : #adding }
GPContextFreeGrammar >> createNode: key with: sequence [
	^ GPNode new
		type: key;
		children: (sequence collect: [:val | GPNode new type: val])
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> expandFrom: axiom [
	^ rules at: axiom ifPresent: [ :nodes | self expandNodesFrom: nodes ] ifAbsent: [ nil ]
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> expandNodesFrom: nodes [

	 | collection |
	collection := OrderedCollection new.
	 ^ self expandNodesFrom: nodes given: collection
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> expandNodesFrom: nodes given: collection [

	 | selectedNode |
	 selectedNode := self selectRandomly: nodes.
	 ^ selectedNode isLeaf
		   ifTrue: [
			   collection add:
				   (self selectRandomly: (values at: selectedNode type)).
			   collection ]
		   ifFalse: [ 
			   selectedNode children do: [ :child | 
				   rules
					   at: child type
					   ifPresent: [ 
					   self expandNodesFrom: (rules at: child type) given: collection ]
					   ifAbsent: [ collection add: child ] ] ]
]

{ #category : #initialization }
GPContextFreeGrammar >> initialize [

	rules := Dictionary new.
	values := Dictionary new.
	random := Random seed: 18
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> selectRandomly: collection [
	^ collection at: (random nextInt: collection size)
]
