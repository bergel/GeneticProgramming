Class {
	#name : #GPDigit,
	#superclass : #GPAbstractExpression,
	#instVars : [
		'value'
	],
	#category : #'GeneticProgramming-Examples'
}

{ #category : #accessing }
GPDigit class >> value: anObject [
	^ self new value: anObject 
]

{ #category : #accessing }
GPDigit class >> values [ 	
	^ (1 to: 10) collect: [ :n | self value: n ]
]

{ #category : #comparing }
GPDigit >> = other [
	^ self class = other class 
		and: [ value = other value ]
]

{ #category : #'public access' }
GPDigit >> evaluate: collection with: context [

	 ^ (context selectRandomly: self class values) value
]

{ #category : #evaluating }
GPDigit >> value [ 	
	^ value
]

{ #category : #accessing }
GPDigit >> value: anObject [
	value := anObject 
]
