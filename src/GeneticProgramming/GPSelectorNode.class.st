Class {
	#name : #GPSelectorNode,
	#superclass : #GPAbstractNode,
	#category : #'GeneticProgramming-Core'
}

{ #category : #'collecting leaves' }
GPSelectorNode >> expandGiven: context [

	^ self expandGiven: context depth: 1 method: nil and: #()
]

{ #category : #'collecting leaves' }
GPSelectorNode >> expandGiven: grammar depth: anInteger method: methodName and: booleans [
	"to remove"
	| node |
	anInteger < 1 ifTrue: [ ^ nil ].
	node := self newNode: grammar with: anInteger.
	node nodeValue: (self selectOption: grammar).
	^ node
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
