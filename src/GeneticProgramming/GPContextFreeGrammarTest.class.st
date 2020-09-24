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

	| collection values |
	values := Array
		          with: (GPDigit value: 3)
		          with: (GPDigit value: 4)
		          with: (GPDigit value: 5).
	grammar
		addRule: #E with: #( #E #+ #T );
		addRule: #E with: #( #E #- #T );
		addRule: #E with: #( #T );
		addRule: #T with: #( #T #* #F );
		addRule: #T with: #( #T #/ #F );
		addRule: #T with: #( #F );
		addRule: #F withLeaf: values.
	"	self assert: (grammar hasRule: #F).
	self assert: (grammar hasRule: #T).
	self assert: (grammar hasRule: #E)."
	collection := grammar expandFrom: #T.
	self assert: (#( #( #T #* #F ) #( #T #/ #F ) #( #F ) ) includes:
			 ((grammar expandFrom: #T) collect: #type)).
	self assert: (values includes: (grammar expandFrom: #F) first)
]
