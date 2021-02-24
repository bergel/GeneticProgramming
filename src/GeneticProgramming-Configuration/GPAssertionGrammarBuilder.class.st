Class {
	#name : #GPAssertionGrammarBuilder,
	#superclass : #Object,
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder class >> buildAssertionGrammar: aClass of: selector [
	^ self new buildAssertionGrammar: aClass of: selector
]

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> buildAssertionGrammar: argNames [
	| grammar |
	grammar := GPContextFreeGrammar new.
	grammar 
		addRule: #Assertion ofClass: RBMessageNode withSequence: #(#Self #Assert #Method);
		"addRule: #Assertion ofClass: RBMessageNode withSequence: #(#Self #Assert2 #Method);"
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Message1);
		"addRule: #Method ofClass: RBMessageNode withSequence: #(#Variable #Message2);"
		addRule: #Method ofClass: RBMessageNode withSequence: #(#Method #AndOr #Block);
		addSelectorRule: #Assert withValues: #(#assert:);
		"addSelectorRule: #Assert2 withValues: #(#assert:equals:);"
		addSelectorRule: #Message1 withValues: #(#isString #isCollection #notNil #isSymbol #isEmpty #notEmpty #isNil #isColor);
		"addSelectorRule: #Message2 withValues: #(#isKindOf: #isMemberOf:);"
		addSelectorRule: #AndOr withValues: #(#and: );
		addRule: #Block ofClass: RBBlockNode withSequence: #(#Method);
		addLeafRule: #Self ofClass: RBVariableNode withValues: #('self');
		addLeafRule: #Variable ofClass: RBVariableNode withValues: argNames.
	^ grammar
]

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> buildAssertionGrammar: aClass of: selector [
	| compMethod args |
	compMethod := aClass methodNamed: selector.
	args := compMethod ast arguments collect: #name.
	^ self buildAssertionGrammar: args
]
