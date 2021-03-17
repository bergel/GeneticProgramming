Class {
	#name : #GPCounter,
	#superclass : #Object,
	#instVars : [
		'occurrences'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #adding }
GPCounter class >> addOccurrence: selector [
	instance ifNil: [ instance := self new ].
	instance addOccurrences: selector
	
]

{ #category : #accessing }
GPCounter class >> instance [
	^ instance 
		ifNil: [ instance := self new ] 
		ifNotNil: [ instance ]
]

{ #category : #accessing }
GPCounter class >> reset [
	instance := nil
]

{ #category : #adding }
GPCounter >> addOccurrences: selector [
	| val |
	val := occurrences at: selector 
		ifAbsent: [ 0 ].
	occurrences at: selector put: val + 1
]

{ #category : #initialization }
GPCounter >> initialize [ 
	occurrences := Dictionary new
]

{ #category : #'as yet unclassified' }
GPCounter >> occurrencesDictionary [
	^ occurrences 
]

{ #category : #testing }
GPCounter >> occurrencesOf: tSelector [
	^ occurrences at: tSelector 
		ifAbsent: [ 0 ] 
]
