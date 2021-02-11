Class {
	#name : #GPPlay,
	#superclass : #Object,
	#classVars : [
		'AssertionGP'
	],
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #'as yet unclassified' }
GPPlay >> assertionGP: anExpression [
	AssertionGP := anExpression
]

{ #category : #'helper methods' }
GPPlay >> initialize [
	super initialize.
	AssertionGP ifNil: [ AssertionGP := [ :obj | ] ]
]

{ #category : #'helper methods' }
GPPlay >> m: obj [
	^ AssertionGP value: obj
	"^ (obj isNotNil and: [ obj isCollection ])"
]
