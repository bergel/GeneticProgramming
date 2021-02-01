Class {
	#name : #GPSelectorNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

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
