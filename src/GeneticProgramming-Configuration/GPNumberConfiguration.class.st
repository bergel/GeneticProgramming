Class {
	#name : #GPNumberConfiguration,
	#superclass : #GPPlayConfiguration,
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #operations }
GPNumberConfiguration >> distanceFromSolutionOf: individual [
	| p t |
	p := GPPlay new.
	p assertionGP: [ :obj | individual evaluateWith: { 'obj' -> obj } asDictionary ].
	t := GPNumberTest buildSuite run.
	individual fitness: t runCount + t failureCount + t errorCount - t passedCount.
	^ individual fitness
]

{ #category : #initialization }
GPNumberConfiguration >> initializeGrammar [
	"Should find something like:
		obj isNumber and: [ obj odd ]
		
	Messages the algorithm can use:
		isNil
		or:
		and:
		isCollection
		isNumber
		isByteString
		isFloat
		odd
	"
	grammar := GPContextFreeGrammar new.
	grammar 
		addRule: #E ofClass: RBMessageNode withSequence: #(#E #And #Block);
		"addRule: #E ofClass: RBMessageNode withSequence: #(#Variable #Satisfy #Message);"
		addRule: #E ofClass: RBMessageNode withSequence: #(#Variable #Message);
		addSelectorRule: #And withValues: #(#and:);
		"addSelectorRule: #Satisfy withValues: #(#allSatisfy: #noneSatisfy:);"
		addSelectorRule: #Message withValues: #(#isNil #isCollection #isNumber #isString #isFloat #notNil #notEmpty #odd #even);
		addRule: #Block ofClass: RBBlockNode withSequence: #(#E);
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #('obj').
	"grammar configuration: self."
	^ grammar
]

{ #category : #hooks }
GPNumberConfiguration >> numberOfGenerations [ 
	^ 20
]

{ #category : #accessing }
GPNumberConfiguration >> populationSize [ 
	^ 50
]
