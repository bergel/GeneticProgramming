Class {
	#name : #GPArithConfiguration,
	#superclass : #GPAbstractArithmeticConfiguration,
	#category : #'GeneticProgramming-Configuration-Arithmetic'
}

{ #category : #'as yet unclassified' }
GPArithConfiguration >> calculateFitnessValue: individual [
	^ (individual evaluate - 1273) abs
]

{ #category : #example }
GPArithConfiguration >> example [
	"
	self new example print
	"
	| e |
	e := GPEngine new.
	e configuration: GPArithConfiguration new.
	e execute.
	^ e pickBestIndividual

"
population select: [ :i | (self distanceFromSolutionOf: i) = 9 ]
"
]

{ #category : #operations }
GPArithConfiguration >> newTerminal [
	| res t |
	t := self randomElementOf: #(1 2 3 4 5 6).
	res := GPNode new.
	res nodeValue: t.
	res printBlock: [ :node :context | node nodeValue asString ].
	res evaluationBlock: [ :node :context | node nodeValue ].
	^ res
]
