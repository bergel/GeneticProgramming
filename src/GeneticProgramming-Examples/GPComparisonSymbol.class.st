Class {
	#name : #GPComparisonSymbol,
	#superclass : #Object,
	#instVars : [
		'symbol'
	],
	#category : #'GeneticProgramming-Examples'
}

{ #category : #accessing }
GPComparisonSymbol class >> symbol: symbol [
	^ self new symbol: symbol
]

{ #category : #comparing }
GPComparisonSymbol >> = other [
	^ self class = other class 
		and: [ symbol = other symbol ]
]

{ #category : #accessing }
GPComparisonSymbol >> symbol [
	^ symbol
]

{ #category : #accessing }
GPComparisonSymbol >> symbol: anObject [
	symbol := anObject
]
