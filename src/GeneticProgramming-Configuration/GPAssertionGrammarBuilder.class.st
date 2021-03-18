Class {
	#name : #GPAssertionGrammarBuilder,
	#superclass : #Object,
	#instVars : [
		'arguments'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder class >> buildAssertionGrammar: aClass of: targetSelectors [
	^ self new buildAssertionGrammar: aClass of: targetSelectors
]

{ #category : #accessing }
GPAssertionGrammarBuilder >> argumentsOf: symbol [
	^ arguments at: symbol
]

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> buildAssertionGrammar [
	| grammar |
	grammar := GPContextFreeGrammar new.
	grammar 
		addRule: #Assertion ofClass: RBMessageNode withSequence: #(#Self #Assert #Method);
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Message);
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Message1 #Args1);
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Satisfy #Message);
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Method #AndOr #Block);
		addSelectorRule: #Assert withValues: #(#assert:);
		addSelectorRule: #Message withValues: #(#isString #isCollection #isSymbol #isEmpty #notEmpty #isNil);
		addSelectorRule: #Message1 withValues: #(#isKindOf: #isMemberOf:);
		addSelectorRule: #Satisfy withValues: #(#allSatisfy: #noneSatisfy: #anySatisfy:);
		addSelectorRule: #AndOr withValues: #(#and:);
		addRule: #Args1 withCollectionOptions: #(#Class) ofSize: 1;
		addRule: #Block ofClass: RBBlockNode withSequence: #(#Method);
		addLeafRule: #Self ofClass: RBVariableNode withValues: #('self');
		addLeafRule: #Class ofClass: RBVariableNode  withValues: (Array with: #ByteString) .
	^ grammar
]

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> buildAssertionGrammar: aClass of: targetSelectors [
	self collectArguments: aClass given: targetSelectors.
	^ self buildAssertionGrammar
]

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> collectArguments: aClass given: targetSelectors [
	arguments := (targetSelectors collect: [ :tS | | compMethod |
		compMethod := aClass methodNamed: tS.
		tS -> (compMethod ast arguments collect: #name)
	]) asDictionary
]

{ #category : #initialization }
GPAssertionGrammarBuilder >> initialize [
	arguments := Dictionary new
]
