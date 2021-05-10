Class {
	#name : #GPNodeTest,
	#superclass : #GPAbstractNodeTest,
	#category : #'GeneticProgramming-Tests'
}

{ #category : #'as yet unclassified' }
GPNodeTest >> grammarETF [

	| grammar configuration |
	grammar := GPContextFreeGrammar new.
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #Mul withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #Mul #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10);
		addRule: #F redirectingTo: #E.
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #Add putWeights: #( 6 4 );
		                 forRule: #Mul putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	grammar configuration: configuration.
	^ grammar
]

{ #category : #'as yet unclassified' }
GPNodeTest >> grammarETF2 [

	| grammar configuration |
	grammar := GPContextFreeGrammar new.
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #E );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #Mul withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #Mul #T );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10);
		addRule: #F redirectingTo: #E.
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #Add putWeights: #( 6 4 );
		                 forRule: #Mul putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 );
							  depth: 10.
	grammar configuration: configuration.
	^ grammar
]

{ #category : #'as yet unclassified' }
GPNodeTest >> grammarRoassal [
	| grammar |
	grammar := GPContextFreeGrammar new.
	grammar
		addRule: #Stms
		withCollectionOptions: #( #Assignment #Message ) ofSize: 1;
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Value #Selector );
		addSelectorRule: #Selector withValues: #( #size );
		addRule: #Value withOptions: #( #Message #Variable );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #shapes ).
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
GPNodeTest >> testAst [
	| node ast |
	node := GPNode new 
		id: #F;
		type: RBLiteralNode;
		nodeValue: 1.
	ast := node ast.
	self assert: (RBParser parseExpression: '1') equals: ast
]

{ #category : #tests }
GPNodeTest >> testAstOfMessageNode [
	| node ast |
	node := GPNode new 
		id: #E;
		type: RBMessageNode;
		children: (OrderedCollection new
			add: (GPNode new id: #F; type: RBLiteralNode; nodeValue: 1);
			add: (GPNode new id: #Add; nodeValue: #+);
			add: (GPNode new id: #F; type: RBLiteralNode; nodeValue: 34);
			yourself).
	ast := node ast.
	self assert: (RBParser parseExpression: '1 + 34') equals: ast
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
	
	offspring := c crossoverOf: i1 with: i2 at: 4 at: 2.
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
	
	offspring := c crossover: i1 with: i2.
	self assert: offspring print ~= i1 print.
	self assert: offspring print ~= i2 print.
]

{ #category : #tests }
GPNodeTest >> testCrossOver03 [
	| i1 i2 offspring configuration |
	configuration := GPGrammarConfiguration new.
	GPRandom seed: 1.
	i1 := GPNode new id: #E; type: RBMessageNode;
		printBlock: [:n :ctx | (n generateAST: GPReplacementVisitor new) formattedCode ];
		children: (Array 
			with: (GPNode new id: #Number; type: RBLiteralNode; nodeValue: 3)
			with: (GPNode new id: #Add; nodeValue: #+)
			with: (GPCollectionNode new id: #Args; children: (Array 
				with: (GPNode new id: #Number; type: RBLiteralNode; nodeValue: 7)))).
	i2 := GPNode new id: #F; type: RBMessageNode;
		printBlock: [:n :ctx | (n generateAST: GPReplacementVisitor new) formattedCode ];
		children: (Array 
			with: (GPNode new id: #Number; type: RBLiteralNode; nodeValue: 8)
			with: (GPNode new id: #Selector; nodeValue: #odd)).
	
	self assert: i1 print equals: '3 + 7'.
	self assert: i2 print equals: '8 odd'.
	offspring := configuration crossover: i1 with: i2.
	self deny: offspring print equals: '3 odd 7'.
	self deny: offspring print equals: i1 print.
	self deny: offspring print equals: i2 print.
	self assert: offspring print equals: '8 + 7'
]

{ #category : #tests }
GPNodeTest >> testCrossOver04 [
	| i1 i2 offspring configuration |
	GPRandom seed: 163.
	configuration := GPGrammarConfiguration new.
	i1 := GPNode new id: #E; type: RBMessageNode;
		printBlock: [:n :ctx | n ast formattedCode ];
		evaluationBlock: [ :n :ctx | n ast ];
		children: (Array 
			with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
			with: (GPSelectorNode new id: #Satisfy; nodeValue: #allSatisfy:)
			with: (GPSelectorNode new id: #Message; nodeValue: #isCollection)).
	i2 := GPNode new id: #E; type: RBMessageNode;
		printBlock: [:n :ctx | n ast formattedCode ];
		evaluationBlock: [ :n :ctx | n ast ];
		children: (Array 
			with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj1')
			with: (GPSelectorNode new id: #Message; nodeValue: #isNotNil)).
	
	self assert: i1 print equals: 'obj allSatisfy: #isCollection'.
	self assert: i2 print equals: 'obj1 isNotNil'.
	offspring := configuration crossover: i1 with: i2.
	self deny: offspring print equals: i1 print.
	self deny: offspring print equals: i2 print.
	self assertCollection: (Array with: offspring print) includesAny: #('obj allSatisfy: #isNotNil' 'obj1 allSatisfy: #isNotNil' 'obj1 allSatisfy: #isCollection').
]

{ #category : #tests }
GPNodeTest >> testCrossOver05 [
	| i1 i2 offspring configuration |
	GPRandom seed: 163.
	configuration := GPGrammarConfiguration new.
	i1 := GPNode new id: #E; type: RBMessageNode;
		printBlock: [:n :ctx | n ast formattedCode ];
		children: (Array 
			with: (GPLeafNode new id: #Number; type: RBLiteralNode; nodeValue: 3)
			with: (GPSelectorNode new id: #Add; nodeValue: #+)
			with: (GPCollectionNode new id: #Args; children: (Array 
				with: (GPLeafNode new id: #Number; type: RBLiteralNode; nodeValue: 7)))).
	i2 := GPNode new id: #F; type: RBMessageNode;
		printBlock: [:n :ctx | n ast formattedCode ];
		children: (Array 
			with: (GPLeafNode new id: #Number; type: RBLiteralNode; nodeValue: 8)
			with: (GPSelectorNode new id: #Add; nodeValue: #-)
			with: (GPCollectionNode new id: #Args; children: (Array 
				with: (GPLeafNode new id: #Number; type: RBLiteralNode; nodeValue: 9)))).
	
	self assert: i1 print equals: '3 + 7'.
	self assert: i2 print equals: '8 - 9'.
	offspring := configuration crossover: i1 with: i2.
	self deny: offspring print equals: i1 print.
	self deny: offspring print equals: i2 print.
	self assert: offspring print equals: '3 - 7'.
]

{ #category : #tests }
GPNodeTest >> testCrossOver06 [
	| i1 i2 offspring configuration |
	GPRandom seed: 1.
	configuration := GPGrammarConfiguration new.
	i1 := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
			with: (GPSelectorNode new id: #Satisfy; nodeValue: #noneSatisfy:)
			with: (GPSelectorNode new id: #Message; nodeValue: #isNumber)).
	i2 := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPNode new id: #E; type: RBMessageNode; 
				children: (Array 
					with: (GPNode new id: #E; type: RBMessageNode; 
						children: (Array 
							with: (GPNode new id: #E; type: RBMessageNode; 
								children: (Array 
									with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
									with: (GPSelectorNode new id: #Message; nodeValue: #isString)))
							with: (GPSelectorNode new id: #And; nodeValue: #and:)
							with: (GPNode new id: #Block; type: RBBlockNode; 
								children: (Array 
									with: (GPNode new id: #E; type: RBMessageNode;
										children: (Array 
											with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
											with: (GPSelectorNode new id: #Message; nodeValue: #notNil)))))))
					with: (GPSelectorNode new id: #And; nodeValue: #and: )
					with: (GPNode new id: #Block; type: RBBlockNode;
						children: (Array 
							with: (GPNode new id: #E; type: RBMessageNode;
								children: (Array 
									with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
									with: (GPSelectorNode new id: #Message; nodeValue: #isFloat ) ))))))
			with: (GPSelectorNode new id: #And; nodeValue: #and:)
			with: (GPNode new id: #Block; type: RBBlockNode; 
				children: (Array 
					with: (GPNode new id: #E; type: RBMessageNode;
					children: (Array 
						with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
						with: (GPSelectorNode new id: #Satisfy; nodeValue: #allSatisfy:)
						with: (GPSelectorNode new id: #Message; nodeValue: #isString)))))).
	self assert: i1 ast formattedCode equals: 'obj noneSatisfy: #isNumber'.
	self assert: i2 ast formattedCode equals: '((obj isString and: [ obj notNil ]) and: [ obj isFloat ]) and: [ 
	obj allSatisfy: #isString ]'.
	offspring := configuration crossover: i1 with: i2.
	self deny: offspring ast formattedCode equals: i1 ast formattedCode.
	self deny: offspring ast formattedCode equals: i2 ast formattedCode.
	self assert: offspring ast formattedCode equals: 'obj allSatisfy: #isNumber'.
]

{ #category : #tests }
GPNodeTest >> testCrossOver07 [
	| i1 i2 offspring configuration |
	GPRandom seed: 1.
	configuration := GPGrammarConfiguration new.
	i1 := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPNode new id: #E; type: RBMessageNode; 
				children: (Array 
					with: (GPNode new id: #E; type: RBMessageNode; 
						children: (Array 
							with: (GPNode new id: #E; type: RBMessageNode; 
								children: (Array 
									with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
									with: (GPSelectorNode new id: #Message; nodeValue: #isString));
								printBlock: [:n :ctx | n ast formattedCode ])
							with: (GPSelectorNode new id: #And; nodeValue: #and:)
							with: (GPNode new id: #Block; type: RBBlockNode; 
								children: (Array 
									with: (GPNode new id: #E; type: RBMessageNode;
										children: (Array 
											with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
											with: (GPSelectorNode new id: #Message; nodeValue: #notNil));
										printBlock: [:n :ctx | n ast formattedCode ]));
								printBlock: [:n :ctx | n ast formattedCode ]));
						printBlock: [:n :ctx | n ast formattedCode ])
					with: (GPSelectorNode new id: #And; nodeValue: #and: )
					with: (GPNode new id: #Block; type: RBBlockNode;
						children: (Array 
							with: (GPNode new id: #E; type: RBMessageNode;
								children: (Array 
									with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
									with: (GPSelectorNode new id: #Message; nodeValue: #isFloat ));
								printBlock: [:n :ctx | n ast formattedCode ]));
						printBlock: [:n :ctx | n ast formattedCode ]));
				printBlock: [:n :ctx | n ast formattedCode ])
			with: (GPSelectorNode new id: #And; nodeValue: #and:)
			with: (GPNode new id: #Block; type: RBBlockNode; 
				children: (Array 
					with: (GPNode new id: #E; type: RBMessageNode;
					children: (Array 
						with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
						with: (GPSelectorNode new id: #Satisfy; nodeValue: #allSatisfy:)
						with: (GPSelectorNode new id: #Message; nodeValue: #isString));
					printBlock: [:n :ctx | n ast formattedCode ]));
				printBlock: [:n :ctx | n ast formattedCode ]));
		printBlock: [:n :ctx | n ast formattedCode ].
	i2 := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
			with: (GPSelectorNode new id: #Satisfy; nodeValue: #noneSatisfy:)
			with: (GPSelectorNode new id: #Message; nodeValue: #isNumber));
		printBlock: [:n :ctx | n ast formattedCode ].
	self assert: i1 print equals: '((obj isString and: [ obj notNil ]) and: [ obj isFloat ]) and: [ 
	obj allSatisfy: #isString ]'.
	self assert: i2 print equals: 'obj noneSatisfy: #isNumber'.
	offspring := configuration crossover: i1 with: i2.
	self deny: offspring print equals: i1 print.
	self deny: offspring print equals: i2 print.
	self assert: offspring print equals: '((obj isNumber and: [ obj notNil ]) and: [ obj isFloat ]) and: [ 
	obj allSatisfy: #isString ]'.
]

{ #category : #tests }
GPNodeTest >> testCrossOver08 [
	| i1 i2 offspring configuration |
	GPRandom seed: 1.
	configuration := GPGrammarConfiguration new.
	i1 := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPNode new id: #E; type: RBMessageNode; 
				children: (Array 
					with: (GPNode new id: #E; type: RBMessageNode; 
						children: (Array 
							with: (GPNode new id: #E; type: RBMessageNode; 
								children: (Array 
									with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
									with: (GPSelectorNode new id: #Message; nodeValue: #isString));
								printBlock: [:n :ctx | n ast formattedCode ])
							with: (GPSelectorNode new id: #And; nodeValue: #and:)
							with: (GPNode new id: #Block; type: RBBlockNode; 
								children: (Array 
									with: (GPNode new id: #E; type: RBMessageNode;
										children: (Array 
											with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
											with: (GPSelectorNode new id: #Message; nodeValue: #notNil));
										printBlock: [:n :ctx | n ast formattedCode ]));
								printBlock: [:n :ctx | n ast formattedCode ]));
						printBlock: [:n :ctx | n ast formattedCode ])
					with: (GPSelectorNode new id: #And; nodeValue: #and: )
					with: (GPNode new id: #Block; type: RBBlockNode;
						children: (Array 
							with: (GPNode new id: #E; type: RBMessageNode;
								children: (Array 
									with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
									with: (GPSelectorNode new id: #Message; nodeValue: #isFloat ));
								printBlock: [:n :ctx | n ast formattedCode ]));
						printBlock: [:n :ctx | n ast formattedCode ]));
				printBlock: [:n :ctx | n ast formattedCode ])
			with: (GPSelectorNode new id: #And; nodeValue: #and:)
			with: (GPNode new id: #Block; type: RBBlockNode; 
				children: (Array 
					with: (GPNode new id: #E; type: RBMessageNode;
					children: (Array 
						with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
						with: (GPSelectorNode new id: #Satisfy; nodeValue: #allSatisfy:)
						with: (GPSelectorNode new id: #Message; nodeValue: #isString));
					printBlock: [:n :ctx | n ast formattedCode ]));
				printBlock: [:n :ctx | n ast formattedCode ]));
		printBlock: [:n :ctx | n ast formattedCode ].
	i2 := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
			with: (GPSelectorNode new id: #Satisfy; nodeValue: #noneSatisfy:)
			with: (GPSelectorNode new id: #Message; nodeValue: #isNumber));
		printBlock: [:n :ctx | n ast formattedCode ].
	self assert: i1 print equals: '((obj isString and: [ obj notNil ]) and: [ obj isFloat ]) and: [ 
	obj allSatisfy: #isString ]'.
	self assert: i2 print equals: 'obj noneSatisfy: #isNumber'.
	offspring := configuration crossover: i1 with: i2.
	self deny: offspring print equals: i1 print.
	self deny: offspring print equals: i2 print.
	self assert: offspring print equals: '((obj isNumber and: [ obj notNil ]) and: [ obj isFloat ]) and: [ 
	obj allSatisfy: #isString ]'.
]

{ #category : #tests }
GPNodeTest >> testDeepCopy [
	| node c |
	c := GPArithConfiguration new.
	node := c subNode children: { c number: 5 . (c multNode children: { c number: 2 . c number: 3 }) }.
	^ self testDeepCopy: node
]

{ #category : #tests }
GPNodeTest >> testExpandGivenDepthMethodAnd [
	| grammar node |
	grammar := self grammarETF2.
	grammar methodName: #full.
	GPRandom seed: 1.
	node := grammar expandTree: #E.
	self assert: (node allLeaves select: #isLeafNode thenCollect: #depth) asSet size equals: 1.
	self assertCollection: (node allLeaves select: #isLeafNode thenCollect: #depth) asSet equals: (Set new add: 10; yourself)
]

{ #category : #tests }
GPNodeTest >> testExpandGivenDepthMethodAndGrow [
	| grammar node stack |
	grammar := self grammarETF.
	GPRandom seed: 10.
	node := grammar expandTree: #E.
	stack := Stack new.
	"node := node expandGiven: grammar depth: 4 method: #grow and: stack."
	self assert: (node allLeaves select: #isLeafNode thenCollect: #depth) asSet size > 1
]

{ #category : #tests }
GPNodeTest >> testExpandGivenDepthMethodAndOnCollectionNode [
	| grammar node |
	grammar := self grammarRoassal.
	GPRandom seed: 1.
	node := grammar expandTree: #Stms.
	"node := node expandGiven: grammar depth: 4 method: #grow and: Stack new."
	self assertCollection: node nodeValue flattened hasSameElements: #(#shapes #size)
]

{ #category : #tests }
GPNodeTest >> testMutate [
	| c i p |
	GPRandom seed: 1219.
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

{ #category : #tests }
GPNodeTest >> testMutate3 [
	| c i p |
	c := GPPlayConfiguration new.
	GPRandom seed: 1.
	i := GPLeafNode new 
		id: #Variable; 
		type: RBVariableNode; 
		nodeValue: 'obj1'; 
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ].
	self assert: i evaluate equals: (RBParser parseExpression: 'obj1').
	self assert: i print equals: 'obj1'.
	p := (1 to: 20) collect: [ :n | 
		c mutate: i.
		i print
		 ].
	self assert: p asSet size equals: 1.
	 
]

{ #category : #tests }
GPNodeTest >> testMutate4 [
	| c i p |
	c := GPPlayConfiguration new.
	GPRandom seed: 1.
	i := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj1')
			with: (GPSelectorNode new id: #Satisfy; nodeValue: #noneSatisfy:)
			with: (GPSelectorNode new id: #Message; nodeValue: #isNil));
		printBlock: [:n :ctx | n ast formattedCode ];
		evaluationBlock: [:n :ctx | n ast ].
	self assert: i evaluate equals: (RBParser parseExpression: 'obj1 noneSatisfy: #isNil').
	self assert: i print equals: 'obj1 noneSatisfy: #isNil'.
	p := (1 to: 20) collect: [ :n | 
		c mutate: i.
		i print ].
	self assert: p asSet size > 1.
	 
]

{ #category : #tests }
GPNodeTest >> testMutate5 [
	| c i p |
	c := GPPlayConfiguration new.
	GPRandom seed: 1.
	i := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj1')
			with: (GPSelectorNode new id: #And; nodeValue: #and:)
			with: (GPNode new id: #Block; type: RBBlockNode; 
				children: (Array with: (GPNode new id: #E;
					type: RBMessageNode;
					children: (Array with:
						(GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj1')
						with: (GPSelectorNode new id: #Message; nodeValue: #isCollection));
					evaluationBlock: [:n :ctx | n ast ];
					printBlock: [:n :ctx | n ast formattedCode ]));
				evaluationBlock: [:n :ctx | n ast ];
				printBlock: [:n :ctx | n ast formattedCode ]));
		printBlock: [:n :ctx | n ast formattedCode ];
		evaluationBlock: [:n :ctx | n ast ].
	self assert: i evaluate equals: (RBParser parseExpression: 'obj1 and: [ obj1 isCollection ]').
	self assert: i print equals: 'obj1 and: [ obj1 isCollection ]'.
	p := (1 to: 20) collect: [ :n | 
		c mutate: i.
		i print ].
	self assert: p asSet size > 1.
	 
]

{ #category : #tests }
GPNodeTest >> testMutate6 [
	| c i p |
	c := GPPlayConfiguration new.
	GPRandom seed: 1.
	i := GPNode new id: #E; 
		type: RBMessageNode;
		children:  (Array 
			with: (GPNode new id: #E; type: RBMessageNode; 
				children: (Array 
					with: (GPNode new id: #E; type: RBMessageNode; 
						children: (Array 
							with: (GPNode new id: #E; type: RBMessageNode; 
								children: (Array 
									with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
									with: (GPSelectorNode new id: #Message; nodeValue: #isString));
								printBlock: [:n :ctx | n ast formattedCode ])
							with: (GPSelectorNode new id: #And; nodeValue: #and:)
							with: (GPNode new id: #Block; type: RBBlockNode; 
								children: (Array 
									with: (GPNode new id: #E; type: RBMessageNode;
										children: (Array 
											with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
											with: (GPSelectorNode new id: #Message; nodeValue: #notNil));
										printBlock: [:n :ctx | n ast formattedCode ]));
								printBlock: [:n :ctx | n ast formattedCode ]));
						printBlock: [:n :ctx | n ast formattedCode ])
					with: (GPSelectorNode new id: #And; nodeValue: #and: )
					with: (GPNode new id: #Block; type: RBBlockNode;
						children: (Array 
							with: (GPNode new id: #E; type: RBMessageNode;
								children: (Array 
									with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
									with: (GPSelectorNode new id: #Message; nodeValue: #isFloat ));
								printBlock: [:n :ctx | n ast formattedCode ]));
						printBlock: [:n :ctx | n ast formattedCode ]));
				printBlock: [:n :ctx | n ast formattedCode ])
			with: (GPSelectorNode new id: #And; nodeValue: #and:)
			with: (GPNode new id: #Block; type: RBBlockNode; 
				children: (Array 
					with: (GPNode new id: #E; type: RBMessageNode;
					children: (Array 
						with: (GPLeafNode new id: #Variable; type: RBVariableNode; nodeValue: 'obj')
						with: (GPSelectorNode new id: #Satisfy; nodeValue: #allSatisfy:)
						with: (GPSelectorNode new id: #Message; nodeValue: #isString));
					printBlock: [:n :ctx | n ast formattedCode ]));
				printBlock: [:n :ctx | n ast formattedCode ]));
		printBlock: [:n :ctx | n ast formattedCode ].
	self assert: i print equals: '((obj isString and: [ obj notNil ]) and: [ obj isFloat ]) and: [ 
	obj allSatisfy: #isString ]'.
	p := (1 to: 20) collect: [ :n | 
		c mutate: i.
		i print ].
	self assert: p asSet size > 1.
	 
]

{ #category : #tests }
GPNodeTest >> testNodeValueForComplexNode [
	| grammar node |
	grammar := self grammarETF.
	GPRandom seed: 48393.
	node := grammar expandTree: #E.
	self assertCollection: node nodeValue flattened hasSameElements: #(6 #* 8).
	

]

{ #category : #tests }
GPNodeTest >> testNodeValueForLeafNode [
	| grammar node |
	grammar := self grammarETF.
	GPRandom seed: 3.
	node := grammar expandTree: #F.
	self assert: node nodeValue equals: 6.
	

]

{ #category : #tests }
GPNodeTest >> testNodeValueForMessageNode [
	| grammar node |
	grammar := self grammarETF.
	GPRandom seed: 1.
	node := grammar expandTree: #Add.
	self assert: node nodeValue equals: #-.
	

]
