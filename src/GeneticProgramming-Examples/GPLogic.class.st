Class {
	#name : #GPLogic,
	#superclass : #GPAbstractExpression,
	#instVars : [
		'value1',
		'logicOperator',
		'value2'
	],
	#category : #'GeneticProgramming-Examples'
}

{ #category : #'public access' }
GPLogic >> evaluate [
	^ value1 perform: logicOperator with: value2 
]

{ #category : #'public access' }
GPLogic >> evaluate: collection with: context [

	 self value1: (collection first evaluate: context).
	 self logicOperator: (collection second evaluate: context).
	 self value2: (collection third evaluate: context).
	 ^ self evaluate
]

{ #category : #accessing }
GPLogic >> logicOperator [
	^ logicOperator
]

{ #category : #accessing }
GPLogic >> logicOperator: aSymbol [

	 aSymbol = #& ifTrue: [ logicOperator := #and: ] ifFalse: [ aSymbol = #| ifTrue: [ logicOperator := #or: ] ifFalse: [ self error: 'Improper symbol' ] ].
	 
]

{ #category : #accessing }
GPLogic >> value1 [
	^ value1
]

{ #category : #accessing }
GPLogic >> value1: anObject [
	value1 := anObject
]

{ #category : #accessing }
GPLogic >> value2 [
	^ value2
]

{ #category : #accessing }
GPLogic >> value2: anObject [
	value2 := anObject
]
