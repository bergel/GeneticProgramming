Class {
	#name : #GPDigit,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #'GeneticProgramming-Examples'
}

{ #category : #accessing }
GPDigit class >> value: anObject [
	^ self new value: anObject 
]

{ #category : #comparing }
GPDigit >> = other [
	^ self class = other class 
		and: [ value = other value ]
]

{ #category : #evaluating }
GPDigit >> value [ 	
	^ value
]

{ #category : #accessing }
GPDigit >> value: anObject [
	value := anObject 
]
