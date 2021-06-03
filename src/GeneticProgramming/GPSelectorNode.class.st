Class {
	#name : #GPSelectorNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #comparing }
GPSelectorNode >> = other [
	^ super = other 
		and: [ self id == other id 
			and: [ nodeValue = other nodeValue 
				"and: [ depth == other depth ]" ] ]
]

{ #category : #'as yet unclassified' }
GPSelectorNode >> convertToLeafNode [
	^ GPLeafNode new 
		id: id; 
		type: RBLiteralNode; 
		nodeValue: nodeValue; 
		depth: depth
]

{ #category : #translating }
GPSelectorNode >> generateAST: visitor [

	^ nodeValue "visitor randomlySelectOption: id"
]

{ #category : #initialization }
GPSelectorNode >> initialize [ 
	super initialize.
	printBlock := [ :n :ctx | nodeValue ]
]

{ #category : #testing }
GPSelectorNode >> isSelectorNode [

	^ true
]

{ #category : #initialization }
GPSelectorNode >> printOn: aStream [

	aStream nextPutAll: (id ifNil: [ nodeValue asString ] ifNotNil: [ id ])
]
