Class {
	#name : #GPCollectionConfiguration,
	#superclass : #GPPlayConfiguration,
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #accessing }
GPCollectionConfiguration >> depth [
	^ 10
]

{ #category : #initialization }
GPCollectionConfiguration >> initialize [
	super initialize.
	testClass := GPCollectionTest
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
