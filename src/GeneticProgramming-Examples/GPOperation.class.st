Class {
	#name : #GPOperation,
	#superclass : #GPAbstractExpression,
	#instVars : [
		'operator',
		'left',
		'right'
	],
	#category : #'GeneticProgramming-Examples'
}

{ #category : #'as yet unclassified' }
GPOperation class >> operator: symbol left: object1 right: object2 [
	^ self new operator: symbol;
		left: object1;
		right: object2 
]

{ #category : #'public access' }
GPOperation >> evaluate [
	^ left perform: operator with: right
]

{ #category : #'public access' }
GPOperation >> evaluate: collection with: context [

	 ^ collection size == 3
		   ifTrue: [ 
			   left := collection first
				           evaluate: context.
			   operator := collection second id.
			   right := collection third
				            evaluate: context.
			   self evaluate ]
		   ifFalse: [ nil ]
]

{ #category : #accessing }
GPOperation >> left [
	^ left
]

{ #category : #accessing }
GPOperation >> left: anObject [
	left := anObject
]

{ #category : #accessing }
GPOperation >> operator [
	^ operator
]

{ #category : #accessing }
GPOperation >> operator: anObject [
	operator := anObject
]

{ #category : #accessing }
GPOperation >> right [
	^ right
]

{ #category : #accessing }
GPOperation >> right: anObject [
	right := anObject
]
