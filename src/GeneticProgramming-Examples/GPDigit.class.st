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

{ #category : #accessing }
GPDigit >> div: digit [

	 ^ self class new value: (self value / digit value)
]

{ #category : #accessing }
GPDigit >> mul: digit [

	 ^ self class new value: self value * digit value
]

{ #category : #accessing }
GPDigit >> sub: digit [

	 ^ self class new value: self value - digit value
]

{ #category : #'math functions' }
GPDigit >> sum: digit [

	 ^ self class new value: self value + digit value
]

{ #category : #evaluating }
GPDigit >> value [ 	
	^ value
]

{ #category : #accessing }
GPDigit >> value: anObject [
	value := anObject 
]
