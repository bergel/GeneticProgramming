Class {
	#name : #GPExpression,
	#superclass : #Object,
	#instVars : [
		'random'
	],
	#category : #'GeneticProgramming-AST'
}

{ #category : #copying }
GPExpression >> deepCopy [ 
	^ self subclassResponsibility 
]

{ #category : #'public access' }
GPExpression >> evaluate [ 
	^ self subclassResponsibility 
]

{ #category : #initialization }
GPExpression >> initialize [ 
	super initialize.
	random := Random seed: 42
]

{ #category : #operations }
GPExpression >> mutate [
	self subclassResponsibility 
]

{ #category : #printing }
GPExpression >> printOn: stream [
	super printOn: stream.
	self subclassResponsibility 
]
