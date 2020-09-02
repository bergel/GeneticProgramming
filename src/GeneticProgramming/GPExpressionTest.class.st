Class {
	#name : #GPExpressionTest,
	#superclass : #TestCase,
	#category : #'GeneticProgramming-Tests'
}

{ #category : #tests }
GPExpressionTest >> test1 [
	| literal literal2 |
	literal := GPLiteral value: 2.
	self assert: literal printString equals: '2'.
	self assert: literal evaluate equals: 2.
	literal2 := literal mutate.
	self deny: literal2 evaluate equals: literal evaluate 
]

{ #category : #tests }
GPExpressionTest >> test2 [
	| message message2 |
	message := GPMessage receiver: (GPLiteral value: 3) message: (GPSelector name: #even) .
	self assert: message printString equals: '3 even'.
	self assert: message evaluate equals: false.
	message2 := message mutate.
	self deny: message receiver evaluate equals: message2 receiver evaluate
]

{ #category : #tests }
GPExpressionTest >> test3 [
	| operation operation2 |
	operation := GPMessage receiver: (GPLiteral value: 2) message: (GPSelector name: #+) args: { GPLiteral value: 3 }.
	self assert: operation printString equals: '2 + 3'.
	self assert: operation evaluate equals: 5.
	operation2 := operation mutate.
	self deny: (operation2 receiver value = 2 and: [operation2 args first value = 3]).
	self deny: operation2 evaluate equals: operation evaluate.
	"message := GPMessage receiver: (GPVariable name: 'a') message: #> args: { GPVariable name: 'b' }."
]

{ #category : #tests }
GPExpressionTest >> test4 [
	| operation operation2 |
	operation := GPMessage receiver: (GPLiteral value: 2) message: (GPSelector name: #+) args: { (GPMessage receiver: (GPLiteral value: 3) message: (GPSelector name: #*) args: {GPLiteral value: 9}) }.
	self assert: operation evaluate equals: 29.
	operation2 := operation mutate.
	self deny: operation2 evaluate equals: operation evaluate
]

{ #category : #tests }
GPExpressionTest >> test5 [
	| operation operation2 |
	operation := GPMessage receiver: (GPMessage receiver: (GPLiteral value: 2) 
	message: (GPSelector name: #-) args: { GPLiteral value: 3}) message: (GPSelector name: #+) args: { (GPMessage receiver: (GPLiteral value: 3) message: (GPSelector name: #*) args: {GPLiteral value: 9}) }.
	self assert: operation evaluate equals: 26.
	operation2 := operation mutate.
	self deny: operation2 evaluate equals: operation evaluate
]

{ #category : #tests }
GPExpressionTest >> test6 [
	| block block2 |
	block := GPBlock new addExpr: (GPLiteral value: true).
	self assert: block print equals: '[true]'.
	self assert: block evaluate equals: true.
	block2 := block mutate.
	self deny: block2 evaluate equals: block evaluate
]
