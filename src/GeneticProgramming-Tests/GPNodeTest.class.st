Class {
	#name : #GPNodeTest,
	#superclass : #TestCase,
	#category : #'GeneticProgramming-Tests'
}

{ #category : #'as yet unclassified' }
GPNodeTest >> grammarETF [
	| grammar configuration |
	grammar := GPContextFreeGrammar new.
	grammar
		addMessageRule: #AddOp withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10).
	configuration := GPASTConfiguration new
		                 addWeight: 8 forRule: #E;
		                 addWeight: 5 forRule: #T;
		                 addWeight: 4 forRule: #F;
		                 addOptionWeights: #( 8 5 ) forRule: #E;
		                 addOptionWeights: #( 6 3 ) forRule: #T;
		                 addOptionWeights: #( 6 4 ) forRule: #AddOp;
		                 addOptionWeights: #( 6 3 ) forRule: #MulOp;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #F.
		grammar configuration: configuration.
		^ grammar
]

{ #category : #running }
GPNodeTest >> setUp [

	GPRandom seed: 75314
]

{ #category : #running }
GPNodeTest >> tearDown [ 
	GPRandom resetInstance
]

{ #category : #tests }
GPNodeTest >> testCrossOver [
	| i1 i2 offspring c |
	c := GPArithConfiguration new.
	"i1 = (5 + (4 * 3))"
	i1 := c sumNode children: { c number: 5 . (c multNode children: { c number: 4 . c number: 3 }) }.
	
	"i2 = (5 * (1 + (6 - 3)))"	
	i2 := c multNode children: { c number: 5 . (c sumNode children: { c number: 1 . (c subNode children: {c number: 6 . c number: 3}) } ) }.
	
	self assert: i1 evaluate equals: 17.
	self assert: i2 evaluate equals: 20.
	self assert: i1 print equals: '(5 + (4 * 3))'.
	self assert: i2 print equals: '(5 * (1 + (6 - 3)))'.
	self assert: i1 numberOfNodes equals: 5.
	self assert: i2 numberOfNodes equals: 7.

	self assert: (i1 atIndex: 4) print equals: '4'.
	self assert: (i1 atIndex: 3) print equals: '(4 * 3)'.
	self assert: (i2 atIndex: 3) print equals: '(1 + (6 - 3))'.
	self assert: (i2 atIndex: 2) print equals: '5'.

	offspring := i1 crossOverWith: i2 at: 4 at: 2.
	self assert: offspring print equals: '(5 + (5 * 3))'.
	self assert: i1 print equals: '(5 + (4 * 3))'.
	self assert: i2 print equals: '(5 * (1 + (6 - 3)))'.

]

{ #category : #tests }
GPNodeTest >> testCrossOver02 [
	| i1 i2 offspring c |
	c := GPArithConfiguration new.
	i1 := c subNode children: { c number: 5 . (c multNode children: { c number: 2 . c number: 3 }) }.
	i2 := c multNode children: { c number: 5 . (c sumNode children: { c number: 1 . (c multNode children: {c number: 5 . c number: 3}) } ) }.
	
	self assert: i1 print equals: '(5 - (2 * 3))'.
	self assert: i2 print equals: '(5 * (1 + (5 * 3)))'.
	
	offspring := i1 crossOverWith: i2.
	self assert: offspring print ~= i1 print.
	self assert: offspring print ~= i2 print.
]

{ #category : #tests }
GPNodeTest >> testExpandGivenDepthMethodAnd [
	| grammar node col |
	grammar := self grammarETF.
	GPRandom seed: 1.
	node := grammar nodeOf: #E.
	col := Stack new.
	"grammar configuration methodDepth: #full."
	node := node expandGiven: grammar depth: 2 method: #full and: col.
	self assert: (node allLeaves select: #isLeafNode thenCollect: #depth) asSet size equals: 1
]

{ #category : #tests }
GPNodeTest >> testMutate [
	| c i p |
	c := GPArithConfiguration new.
	i := c subNode children: { c number: 5 . c number: 3 }.
	p := i print.
	self assert: p equals: '(5 - 3)'.
	1 to: 5 do: [:n | 
		c mutate: i.
		self deny: i print equals: p.
		p := i print.
	].
	
]

{ #category : #tests }
GPNodeTest >> testMutate2 [
	| c i p |
	c := GPCELConfiguration new.
	i := c sumNode children: {c multNode children: { c number: 8. (c multNode children: {c number: 7. c number:10 })}. c number: 34 }.
	self assert: i print equals: '((8 * (7 * 10)) + 34)'.
	self assert: i evaluate equals: 594.
	p := (1 to: 20) collect: [ :n | 
		c mutate: i.
		i print
		 ].
	self assert: p asSet size > 1
	 
]
