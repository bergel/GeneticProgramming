Class {
	#name : #GPLog,
	#superclass : #Object,
	#instVars : [
		'bestFitnessValue',
		'averageFitness',
		'generation',
		'worstFitnessValue',
		'population'
	],
	#category : #'GeneticProgramming-Core'
}

{ #category : #accessing }
GPLog >> averageFitness [
	^ averageFitness
]

{ #category : #accessing }
GPLog >> averageFitness: aNumber [
	averageFitness := aNumber
]

{ #category : #accessing }
GPLog >> bestFitnessValue [
	^ bestFitnessValue
]

{ #category : #accessing }
GPLog >> bestFitnessValue: aNumber [
	bestFitnessValue := aNumber
]

{ #category : #accessing }
GPLog >> generation [ 
	^ generation
]

{ #category : #accessing }
GPLog >> generation: aNumber [
	generation := aNumber
]

{ #category : #initialization }
GPLog >> initialize [ 
	population := OrderedCollection new
]

{ #category : #accessing }
GPLog >> population [ 
	^ population
]

{ #category : #accessing }
GPLog >> population: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	population := collection
]

{ #category : #accessing }
GPLog >> worstFitnessValue [
	^ worstFitnessValue
]

{ #category : #accessing }
GPLog >> worstFitnessValue: aNumber [
	worstFitnessValue := aNumber
]
