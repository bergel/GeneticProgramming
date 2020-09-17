Class {
	#name : #GPLiteral,
	#superclass : #GPExpression,
	#instVars : [
		'value'
	],
	#category : #'GeneticProgramming-AST'
}

{ #category : #accessing }
GPLiteral class >> value: anObject [
	^ self new value: anObject 
]

{ #category : #copying }
GPLiteral >> deepCopy [ 
	^ self class new 
		value: self evaluate 
]

{ #category : #'public access' }
GPLiteral >> evaluate [ 
	^ value evaluate
]

{ #category : #operations }
GPLiteral >> mutate [
	^ self deepCopy value: (value evaluate isNumber ifTrue: [ value evaluate + 10 ] ifFalse: [ value evaluate not ])
]

{ #category : #printing }
GPLiteral >> printOn: stream [
	stream nextPutAll: self evaluate asString 
]

{ #category : #accessing }
GPLiteral >> value [
	^ value
]

{ #category : #accessing }
GPLiteral >> value: aValue [
	value := RBLiteralNode value: aValue
]
