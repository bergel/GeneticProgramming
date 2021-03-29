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
GPAssertionGrammarBuilder >> buildAssertionGrammar: aClass of: targetSelectors [
	self collectArguments: aClass given: targetSelectors.
	^ self buildAssertionGrammarGiven: aClass
]

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> buildAssertionGrammarGiven: tgClass [
	| grammar instVars |
	self assert: tgClass isClass.
	grammar := GPContextFreeGrammar new.
	instVars := self instanceVarsOf: tgClass.
	grammar 
		addRule: #Assertion ofClass: RBMessageNode withSequence: #(#Self #Assert #Method);
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Message);
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Message1 #Args1);
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Satisfy #Message);
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Method #And #Block);
		addSelectorRule: #Assert withValues: #(#assert:);
		addSelectorRule: #Message withValues: #(#isString #isInteger #isFloat #isNumber #isFinite #isCharacter #isCollection #isArray #isSymbol #isColor #isBlock #isEmpty #notEmpty #isNil #notNil #positive #negative #isPoint);
		addSelectorRule: #Message1 withValues: #(#isKindOf: #isMemberOf:);
		addSelectorRule: #Satisfy withValues: #(#allSatisfy: #noneSatisfy: #anySatisfy:);
		addSelectorRule: #And withValues: #(#and:);
		addSelectorRule: #Comparison withValues: #(#= #== #> #<);
		addRule: #Args1 withCollectionOptions: #(#Class) ofSize: 1;
		addRule: #Block ofClass: RBBlockNode withSequence: #(#Method);
		addLeafRule: #Self ofClass: RBVariableNode withValues: #('self');
		addLeafRule: #Class ofClass: RBVariableNode  withValues: #(#ByteString #Point #Character #Symbol #SmallInteger #Number #SmallFloat64 #Boolean #Collection #Array #BlockClosure #Dictionary #Set #OrderedCollection).
	instVars ifNotEmpty: [ 
		grammar 
			addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Comparison #InstanceVar);
			addLeafRule: #InstanceVar ofClass: RBVariableNode withValues: instVars ].
	^ grammar
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

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> instanceVarsOf: tgClass [
	^ tgClass instanceVariables collect: #name
]
