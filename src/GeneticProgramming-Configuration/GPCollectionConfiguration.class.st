Class {
	#name : #GPCollectionConfiguration,
	#superclass : #GPPlayConfiguration,
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #accessing }
GPCollectionConfiguration >> depth [
	^ 10
]

{ #category : #operations }
GPCollectionConfiguration >> distanceFromSolutionOf: individual [
	| p t |
	p := GPPlay new.
	p assertionGP: [ :obj | individual evaluateWith: { 'obj' -> obj } asDictionary ].
	t := GPCollectionTest buildSuite run.
	individual fitness: t runCount + t failureCount + t errorCount - t passedCount.
	^ individual fitness
]

{ #category : #initialization }
GPCollectionConfiguration >> initializeGrammar [
	"Should find something like:
		obj isCollection and: [ obj allSatisfy: #isNumber and: [ obj includes: 4 ] ]
	"
	grammar := GPContextFreeGrammar new.
	grammar 
		addRule: #E ofClass: RBMessageNode withSequence: #(#E #And #Block);
		addRule: #E ofClass: RBMessageNode withSequence: #(#Variable #Satisfy #Message);
		addRule: #E ofClass: RBMessageNode withSequence: #(#Variable #Includes #Obj);
		addRule: #E ofClass: RBMessageNode withSequence: #(#Variable #Message);
		addSelectorRule: #And withValues: #(#and:);
		addSelectorRule: #Satisfy withValues: #(#allSatisfy: #noneSatisfy:);
		addSelectorRule: #Message withValues: #(#isNil #isCollection #isNumber #isString #isFloat #notNil #notEmpty);
		addSelectorRule: #Includes withValues: #(#includes: #includesAny:);
		addRule: #Block ofClass: RBBlockNode withSequence: #(#E);
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #('obj');
		addLeafRule: #Obj ofClass: RBLiteralNode withValues: ( (1 to: 5) asArray ).
	grammar configuration: self.
	^ grammar
]

{ #category : #hooks }
GPCollectionConfiguration >> numberOfGenerations [ 
	^ 30
]

{ #category : #accessing }
GPCollectionConfiguration >> populationSize [ 
	^  150
]
