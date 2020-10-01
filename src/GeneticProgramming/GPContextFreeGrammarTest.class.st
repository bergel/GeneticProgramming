Class {
	#name : #GPContextFreeGrammarTest,
	#superclass : #TestCase,
	#instVars : [
		'grammar'
	],
	#category : #'GeneticProgramming-Tests'
}

{ #category : #running }
GPContextFreeGrammarTest >> setUp [
	super setUp.
	grammar := GPContextFreeGrammar new
]

{ #category : #tests }
GPContextFreeGrammarTest >> test1 [

	 | result |
	 grammar seed: 1.
	 "values := Array
		           with: (GPDigit value: 3)
		           with: (GPDigit value: 4)
		           with: (GPDigit value: 5)."
	 grammar
		 addRule: #E with: GPOperation and: #( #E #+ #T );
		 addRule: #E with: GPOperation and: #( #E #+ #T );
		 addRule: #E with: #T;
		 addRule: #T with: GPOperation and: #( #T #* #F );
		 addRule: #T with: GPOperation and: #( #T #/ #F );
		 addRule: #T with: #F;
		 addRule: #F withLeaf: GPDigit. "values"
	 result := grammar expandFrom: #T.
	 "result -> 			T
						T	*	F
					 T * F
					 F"
	 self assert: result id equals: #T.
	 self assert: result numberOfNodes equals: 8.
	 self
		 assertCollection: (result withAllChildren collect: #id)
		 hasSameElements: #( #T #T #T #F #* #F #* #F ).
	 self
		 assertCollection: (result children collect: #id)
		 hasSameElements: #( #T #* #F ).
	 self
		 assertCollection: (result children first children collect: #id)
		 hasSameElements: #( #T #* #F ).
	 self
		 assertCollection:
		 (result children first children first children collect: #id)
		 hasSameElements: #( #F ).
	 self
		 assert: (result evaluate: grammar)
		 equals: 49
]

{ #category : #tests }
GPContextFreeGrammarTest >> test2 [

	 | result |
	 grammar seed: 1.
	 grammar
		 addRule: #E with: GPLogic and: #( #E #& #T );
		 addRule: #E with: GPLogic and: #( #E #| #T );
		 addRule: #E with: #T;
		 addRule: #T withLeaf: GPBool.
	 result := grammar expandFrom: #E.
	 "result -> 			E
						E	&	T
					 E & T
					 T"
	 self assert: result numberOfNodes equals: 8.
	 self
		 assertCollection: (result withAllChildren collect: #id)
		 hasSameElements: #( #E #E #E #T #& #T #& #T ).
	 self
		 assert: (result evaluate: grammar)
		 equals: false
]
