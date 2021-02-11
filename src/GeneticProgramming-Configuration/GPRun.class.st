Class {
	#name : #GPRun,
	#superclass : #Object,
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #'as yet unclassified' }
GPRun >> averageRun [
	"self new averageRun"

	| p |
	p := GPPlay new.
	p assertionGP: [ :obj | obj isNotNil ].
	^ GPPlayTest buildSuite run passedCount
]

{ #category : #'as yet unclassified' }
GPRun >> badRun [
	"self new badRun"

	| p |
	p := GPPlay new.
	p assertionGP: [ :obj | obj ].
	^ GPPlayTest buildSuite run passedCount
]

{ #category : #'as yet unclassified' }
GPRun >> perfectRun [
	"self new perfectRun"

	| p |
	p := GPPlay new.
	p assertionGP: [ :obj | obj isNotNil and: [ obj isCollection ] ].
	^ GPPlayTest buildSuite run passedCount
]

{ #category : #'as yet unclassified' }
GPRun >> run [

	| e |
	e := GPEngine new.
	GPRandom seed: 1342.
	e configuration: GPPlayConfiguration new.
	e execute.
	^ { 
		  e.
		  e pickBestIndividual }
]
