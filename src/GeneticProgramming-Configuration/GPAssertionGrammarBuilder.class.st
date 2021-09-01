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

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> addInstanceVarsOf: tgClass to: grammar [

	| instVars |
	self assert: tgClass isClass.
	instVars := tgClass instanceVariables collect: #name.
	instVars ifNotEmpty: [ 
		grammar
			addRule: #Method
			ofClass: RBMessageNode
			withSequence: #( #Variable #Comparison #InstanceVar );
			addRule: #Inclusion
			ofClass: RBMessageNode
			withSequence: #( #InstanceVar #Includes #Variable );
			addRule: #NegativeInclusion
			ofClass: RBMessageNode
			withSequence: #( #Inclusion #Not );
			addSelectorRule: #Includes withValues: #( #includes: );
			addSelectorRule: #Not withValues: #( #not );
			addLeafRule: #InstanceVar
			ofClass: RBVariableNode
			withValues: instVars;
			addRule: #Method redirectingTo: #Inclusion;
			addRule: #Method redirectingTo: #NegativeInclusion ]
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
		addRule: #Method
		ofClass: RBMessageNode
		withSequence: #( #Variable #Message );
		addRule: #Method
		ofClass: RBMessageNode
		withSequence: #( #Variable #Message1 #Args1 );
		addRule: #Method
		ofClass: RBMessageNode
		withSequence: #( #Variable #Satisfy #Message );
		addRule: #Method
		ofClass: RBMessageNode
		withSequence: #( #Variable #Comparison #Number );
		addRule: #Method
		ofClass: RBMessageNode
		withSequence: #( #Method #And #Block );
		addRule: #Args1 withCollectionOptions: #( #Class ) ofSize: 1;
		addSelectorRule: #Message
		withValues:
			#( #isString #isInteger #isFloat #isNumber #isFinite #isCharacter
			   #isCollection #isArray #isSymbol #isColor #isBlock #isEmpty
			   #notEmpty #isNil #notNil #positive #negative #isPoint #isStream );
		addSelectorRule: #Message1 withValues: #( #isKindOf: #isMemberOf: );
		"addRule: #Message1 redirectingTo: #Comparison;
		addRule: #Message1 redirectingTo: #Satisfy;
		addRule: #Args1 withCollectionOptions: #(#Class #Message #Integer) ofSize: 1;"
		addSelectorRule: #Satisfy
		withValues: #( #allSatisfy: #noneSatisfy: #anySatisfy: );
		addSelectorRule: #Comparison withValues: #( #= #== #> #< #<= #>= );
		addSelectorRule: #And withValues: #( #and: );
		addRule: #Block ofClass: RBBlockNode withSequence: #( #Method );
		addLeafRule: #Number
		ofClass: RBLiteralNode
		withValues: (Set new
				 addAll: (-10 to: 10);
				 addAll: (-10.6 to: 10.6 count: 15);
				 yourself) asOrderedCollection;
		addLeafRule: #Class
		ofClass: RBVariableNode
		withValues:
			#( #ByteString #Point #Character #Symbol #SmallInteger
			   #Number #SmallFloat64 #Boolean #Collection #Array #BlockClosure
			   #Dictionary #Set #OrderedCollection ).
	^ grammar
]

{ #category : #'as yet unclassified' }
GPAssertionGrammarBuilder >> buildAssertionGrammar: targetSelectors of: aClass [

	| grammar |
	grammar := self buildAssertionGrammar.
	self collectArguments: aClass given: targetSelectors.
	self addInstanceVarsOf: aClass to: grammar.
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
