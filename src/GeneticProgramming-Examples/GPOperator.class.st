Class {
	#name : #GPOperator,
	#superclass : #Object,
	#instVars : [
		'operator'
	],
	#category : #'GeneticProgramming-Examples'
}

{ #category : #accessing }
GPOperator class >> operator: symbol [
	^ self new operator: symbol
]

{ #category : #comparing }
GPOperator >> = other [
	^ self class = other class 
		and: [ operator = other operator ]
]

{ #category : #accessing }
GPOperator >> operator [
	^ operator
]

{ #category : #accessing }
GPOperator >> operator: anObject [
	operator := anObject
]
