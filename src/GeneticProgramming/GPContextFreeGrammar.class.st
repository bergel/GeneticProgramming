Class {
	#name : #GPContextFreeGrammar,
	#superclass : #Object,
	#instVars : [
		'rules',
		'random'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #adding }
GPContextFreeGrammar >> addNode: node [

	 rules
		 at: node id
		 ifPresent: [ :col | col add: node ]
		 ifAbsentPut: [ 
			 OrderedCollection new
				 add: node;
				 yourself ]
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol with: anotherSymbol [
	self addRule: symbol with: nil and: (Array with: anotherSymbol) 
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: key with: aClass and: sequence [

	 self addNode: (self createNode: key with: sequence and: aClass)
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: key withLeaf: aClass [

	 self addNode: (self createNode: key with: #(  ) and: aClass).
	 "values at: key put: nodeValues asOrderedCollection"
]

{ #category : #adding }
GPContextFreeGrammar >> createNode: key with: sequence and: aClass [

	 ^ GPNode new
		   id: key;
		   type: aClass;
		   children: (sequence collect: [ :val | GPNode new id: val ])
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> expandFrom: axiom [
	^ rules at: axiom ifPresent: [ :nodes | self expandNodesFrom: nodes ] ifAbsent: [ nil ]
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> expandNodesFrom: nodes [

	 | selectedNode resultNode |
	 selectedNode := self selectRandomly: nodes.
	 resultNode := selectedNode deepCopy.
	 selectedNode isLeaf ifFalse: [ 
		 selectedNode children doWithIndex: [ :child :index | 
			 rules
				 at: child id
				 ifPresent: [ :n | 
				 resultNode children at: index put: (self expandNodesFrom: n) ]
				 ifAbsent: [ resultNode children at: index put: child deepCopy ] ] ].
	 ^ resultNode
]

{ #category : #initialization }
GPContextFreeGrammar >> initialize [

	 rules := Dictionary new.
	 random := Random seed: 18
]

{ #category : #'instance creation' }
GPContextFreeGrammar >> seed: number [
	random := Random seed: number
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> selectRandomly: collection [

	 
	 ^ collection at: (random nextInt: collection size)
]
