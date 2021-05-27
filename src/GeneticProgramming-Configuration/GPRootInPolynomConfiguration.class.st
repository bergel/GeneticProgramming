Class {
	#name : #GPRootInPolynomConfiguration,
	#superclass : #GPConfiguration,
	#category : #'GeneticProgramming-Configuration-RootInPolynom'
}

{ #category : #hooks }
GPRootInPolynomConfiguration >> createNewIndividual [
	^ self newFunction
]

{ #category : #'as yet unclassified' }
GPRootInPolynomConfiguration >> crossover: individual1 with: individual2 [
	^ self crossoverOf: individual1 with: individual2 
		at: ([random randomNumber: individual1 numberOfNodes - 1] on: Exception do: [ 0 ]) + 1
		at: ([random randomNumber: individual2 numberOfNodes - 1] on: Exception do: [0]) + 1
]

{ #category : #'as yet unclassified' }
GPRootInPolynomConfiguration >> crossoverOf: individual1 with: individual2 at: index1 at: index2 [
	| copy |
	copy := individual1 deepCopy.
	copy atIndex: index1 put: (individual2 atIndex: index2) deepCopy.
	^ copy
]

{ #category : #operations }
GPRootInPolynomConfiguration >> distanceFromSolutionOf: individual [
	"This method has to return a number that describes how close the individual is to the solution.
	If this returns 0, then the individual is a perfect match
	"
	| context |
	
	context := Dictionary new.
	context at: #a put: 4.
	context at: #b put: -2.
	context at: #c put: 10.
	
	individual fitness: (GPFitnessFunction new
		fitnessValue: (individual evaluateUsing: context) abs;
		objective: [ :fitness | fitness fitnessValue == 0 ]).
	^ individual fitness
]

{ #category : #example }
GPRootInPolynomConfiguration >> example [
	"
	self new example print
	"
	| e |
	e := GPEngine new.
	e configuration: GPRootInPolynomConfiguration new.
	e execute.
	^ e pickBestIndividual


]

{ #category : #'instance creation' }
GPRootInPolynomConfiguration >> newFunction [
	"This method has to return a new function"
	| node |
	node := GPNode new.
	node children: { self newTerminal . self newTerminal . self newTerminal }.
	node evaluationBlock: [ :children :context | 
		((children first evaluateUsing: context) * (children first evaluateUsing: context) * (context at: #a))
		+ ((children second evaluateUsing: context) * (children second evaluateUsing: context) * (context at: #b))
		+ (context at: #c)].
	node printBlock: [ :children :context | 
		'root1: ', children first print, '  root2: ', children second print ].
	^ node
	
	"| node |
	node := GPNode new.
	node children: { self newTerminal . self newTerminal . self newTerminal }.
	node evaluationBlock: [ :children :context | 
		((children first evaluateUsing: context) * (context at: #x) * (context at: #x))
		+ ((children second evaluateUsing: context) * (context at: #x))
		+ (children third evaluateUsing: context)].
	node printBlock: [ :children :context | 
		children first print, 'X^2 + ', 
		children second print, 'X + ',
		children third print ].
	^ node"
]

{ #category : #'instance creation' }
GPRootInPolynomConfiguration >> newTerminal [
	"This method has to return a new function"

	| node t |
	node := GPNode new.
	t := (((self randomInt: 2000) - 1000) / 250) asFloat.
	node printBlock: [ :children :context | t asString ].
	node evaluationBlock: [ :children :context | t ].
	^ node
]

{ #category : #hooks }
GPRootInPolynomConfiguration >> numberOfGenerations [
	^ 200
]
