Class {
	#name : #GPGrammarOldTest,
	#superclass : #TestCase,
	#instVars : [
		'grammar'
	],
	#category : #'GeneticProgramming-Tests'
}

{ #category : #adding }
GPGrammarOldTest >> addDigits: array [
	grammar 
		at: #digit putValues: (array collect: [:num | GPDigit value: num ])
			evaluationBlock: [:node :context | node type value ]
			and: [:node :context | node type value asString ] 
]

{ #category : #adding }
GPGrammarOldTest >> addOperators: array [
	grammar 
		at: #operator putValues: (array collect: [:op | GPOperator operator: op ])
		evaluationBlock: [:node :context | node type operator ]
		and: [ :node :context | node type operator ]
		
]

{ #category : #adding }
GPGrammarOldTest >> addRule: symbol withSequence: array evaluationBlock: evaluationBlock and: printBlock [
	grammar
		at: symbol put: array
		evaluationBlock: evaluationBlock
		and: printBlock.
]

{ #category : #running }
GPGrammarOldTest >> setUp [ 
	grammar := GPGrammarOld new
]

{ #category : #tests }
GPGrammarOldTest >> test1 [
	| digit |
	self addDigits: #(1 3 5 6).
	digit := GPDigit value: 1.
	self assert: (grammar evaluate: digit) equals: 1.
	self assert: (grammar ruleNameOf: digit) equals: #digit.
	self assert: (grammar nodeOf: digit) print equals: '1'.
	digit := GPDigit value: 8.
	self assert: (grammar evaluate: digit) isNil.
	self assert: (grammar ruleNameOf: digit) isNil.
	self assert: (grammar nodeOf: digit) isNil.
	digit := GPDigit value: 5.
	self assert: (grammar evaluate: digit) equals: 5.
	self assert: (grammar ruleNameOf: digit) equals: #digit.
	self assert: (grammar nodeOf: digit) print equals: '5'.
]

{ #category : #tests }
GPGrammarOldTest >> test10 [
	"grammar at: #expression put: #(#(#literal));
	at: #expression put: #(#message);
	at: #literal put: (Array with: RBLiteralNode new);
	at: #message put: #(#receiver #selector #args);
	at: #receiver put: #(#expression);
	at: #selector put: #(#(#+ #- #* #/));
	at: #args put: #(#literal);
	at: #args put: #().
	self assert: (grammar evaluate: (RBLiteralNode value: 4)) equals: #literal.
	self assert: (grammar evaluate: (Array with: (RBLiteralNode value: 1))) equals: #expression.
	self assert: (grammar evaluate: (Array with: (RBLiteralNode new value: 'hello')
	with: (RBLiteralNode value: 1234))) equals: #expression.
	self assert: (grammar evaluate: (GPNode new addChild: (RBLiteralNode value: 789); addChild: #+; addChild: (RBLiteralNode value: 234)))"
]

{ #category : #tests }
GPGrammarOldTest >> test2 [
	| array |
	self addDigits: #(1 2 3 4 5 60).
	grammar
		at: #digits putListOf: #digit
		evaluationBlock: [:node :context | (node children collect: [:child | child evaluateUsing: context ]) sum ]
		and: [:node :context | (node children collect: [ :child | child printUsing: context ]) asString ].
	array := Array with: (GPDigit value: 1) with: (GPDigit value: 5).
	self assert: (grammar evaluate: array) equals: 6.
	self assert: (grammar ruleNameOf: array) equals: #digits.
	self assert: (grammar nodeOf: array) print equals: (OrderedCollection newFrom: #('1' '5')) asString.
	array := Array with: (GPDigit value: 1) with: (GPDigit value: 5) with: (GPDigit value: 60).
	self assert: (grammar evaluate: array) equals: 66.
	self assert: (grammar ruleNameOf: array) equals: #digits.
	self assert: (grammar nodeOf: array) print equals: (OrderedCollection newFrom: #('1' '5' '60')) asString.
	array := Array with: (GPDigit value: 1) with: (GPDigit value: 5) with: (GPDigit value: 7).
	self assert: (grammar evaluate: array) isNil.
	self assert: (grammar ruleNameOf: array) isNil.

]

{ #category : #tests }
GPGrammarOldTest >> test3 [
	| array |
	self addDigits: #(1 3 6 8).
	self addOperators: #(#+ #- #* #/).
	self addRule: #operation
		withSequence: #(#digit #operator #digit) 
		evaluationBlock: [:node :context | 
			(node children first evaluateUsing: context) 
				perform: (node children second evaluateUsing: context) 
				with: (node children third evaluateUsing: context) ] 
		and: [ :node :context | 
			String streamContents: [:str | str
				nextPut: $(;
				nextPutAll: (node children first printUsing: context);
				nextPutAll: (node children second printUsing: context);
				nextPutAll: (node children third printUsing: context);
				nextPut: $) ] ].
	array := Array with: (GPDigit value: 1) 
				with: (GPOperator operator: #+) 
				with: (GPDigit value: 3).
	self assert: (grammar evaluate: array) equals: 4.
	self assert: (grammar ruleNameOf: array) equals: #operation.
	self assert: (grammar nodeOf: array) print equals: '(1+3)'.
]

{ #category : #tests }
GPGrammarOldTest >> test4 [
	| array printBlock |
	self addDigits: #(1 2 3 6 8 10).
	self addOperators: #(#+ #- #* #/).
	printBlock := [ :node :context | 
			String streamContents: [:str | str
				nextPut: $(;
				nextPutAll: (node children first printUsing: context);
				nextPutAll: (node children second printUsing: context);
				nextPutAll: (node children third printUsing: context);
				nextPut: $) ] ].
	self addRule: #operation withSequence: #(#digit #operator #digit) 
		evaluationBlock: [:node :context | 
			(node children first evaluateUsing: context) 
				perform: (node children second evaluateUsing: context) 
				with: (node children third evaluateUsing: context) ] 
		and: printBlock.
	grammar 
		at: #expression put: #(#digit) 
			evaluationBlock: [:node :context | node children first evaluateUsing: context ] 
			and: [:node :context | node children first printUsing: context ];
		at: #expression put: #(#operation) 
			evaluationBlock: [:node :context | node children first evaluateUsing: context ]
			and: [:node :context | node children first printUsing: context ]; 
		at: #expression put: #(#expression #operator #expression)
			evaluationBlock: [:node :context | 
				(node children first evaluateUsing: context)
				perform: (node children second evaluateUsing: context)
				with: (node children third evaluateUsing: context) ]
			and: printBlock.
	array := Array 
			with: (Array with: (GPDigit value: 6) 
							with: (GPOperator operator: #+) 
							with: (GPDigit value: 3))
			with: (GPOperator operator: #*)
			with: (Array with: (GPDigit value: 8) 
							with: (GPOperator operator: #/) 
							with: (GPDigit value: 2)).
	self assert: (grammar evaluate: array) equals: 36.
	self assert: (grammar ruleNameOf: array) equals: #expression.
	self assert: (grammar nodeOf: array) print equals: '((6+3)*(8/2))'
]

{ #category : #tests }
GPGrammarOldTest >> test5 [
	"digit -> 1, 2, ...
	operator -> + | - | * | /
	operation -> #digit operator digit 
	expression -> #digit 
	expression -> operation
	expression -> expression operator expression"
	| array printBlock |
	self addDigits: #( 1 2 -3 6 8 10 ).
	self addOperators: #( #+ #- #* #/ ).
	printBlock := [ :node :context | 
	              String streamContents: [ :str | 
		              str
			              nextPut: $(;
			              nextPutAll: (node children first printUsing: context);
			              nextPutAll:
				              (node children second printUsing: context);
			              nextPutAll: (node children third printUsing: context);
			              nextPut: $) ] ].
	self
		addRule: #operation
		withSequence: #( #digit #operator #digit )
		evaluationBlock: [ :node :context | 
			(node children first evaluateUsing: context)
				perform: (node children second evaluateUsing: context)
				with: (node children third evaluateUsing: context) ]
		and: printBlock.
	grammar
		at: #expression
		put: #( #digit )
		evaluationBlock: [ :node :context | 
			node children first evaluateUsing: context ]
		and: [ :node :context | node children first printUsing: context ];
		at: #expression
		put: #( #operation )
		evaluationBlock: [ :node :context | 
			node children first evaluateUsing: context ]
		and: [ :node :context | node children first printUsing: context ];
		at: #expression
		put: #( #expression #operator #expression )
		evaluationBlock: [ :node :context | 
			(node children first evaluateUsing: context)
				perform: (node children second evaluateUsing: context)
				with: (node children third evaluateUsing: context) ]
		and: printBlock.
	array := Array
		         with: (Array
				          with: (GPDigit value: 10)
				          with: (GPOperator operator: #-)
				          with: (GPDigit value: 6))
		         with: (GPOperator operator: #*)
		         with: (Array
				          with: (Array
						           with: (GPDigit value: 8)
						           with: (GPOperator operator: #*)
						           with: (GPDigit value: -3))
				          with: (GPOperator operator: #/)
				          with: (Array
						           with: (GPDigit value: 1)
						           with: (GPOperator operator: #+)
						           with: (GPDigit value: 2))).
	self assert: (grammar evaluate: array) equals: -32.
	self assert: (grammar ruleNameOf: array) equals: #expression.
	self
		assert: (grammar nodeOf: array) print
		equals: '((10-6)*((8*-3)/(1+2)))'
]

{ #category : #tests }
GPGrammarOldTest >> test6 [

	"digit -> 1, 2, ...
	operator -> + | - | * | /
	operation -> #digit operator digit 
	expression -> #digit 
	expression -> operation
	expression -> expression operator expression
	expressions -> expression+"

	| array printBlock |
	self addDigits: #( 1 2 -3 6 8 10 ).
	self addOperators: #( #+ #- #* #/ ).
	printBlock := [ :node :context | 
	              String streamContents: [ :str | 
		              str
			              nextPut: $(;
			              nextPutAll: (node children first printUsing: context);
			              nextPutAll:
				              (node children second printUsing: context);
			              nextPutAll: (node children third printUsing: context);
			              nextPut: $) ] ].
	self
		addRule: #operation
		withSequence: #( #digit #operator #digit )
		evaluationBlock: [ :node :context | 
			(node children first evaluateUsing: context)
				perform: (node children second evaluateUsing: context)
				with: (node children third evaluateUsing: context) ]
		and: printBlock;
		addRule: #expression
		withSequence: #( #digit )
		evaluationBlock: [ :node :context | 
			node children first evaluateUsing: context ]
		and: [ :node :context | node children first printUsing: context ];
		addRule: #expression
		withSequence: #( #operation )
		evaluationBlock: [ :node :context | 
			node children first evaluateUsing: context ]
		and: [ :node :context | node children first printUsing: context ];
		addRule: #expression
		withSequence: #( #expression #operator #expression )
		evaluationBlock: [ :node :context | 
			(node children first evaluateUsing: context)
				perform: (node children second evaluateUsing: context)
				with: (node children third evaluateUsing: context) ]
		and: printBlock.
	grammar
		at: #expressions
		putListOf: #expression
		evaluationBlock: [ :node :context | 
			node children collect: [ :child | child evaluateUsing: context ] ]
		and: [ :node :context | 
			String streamContents: [ :str | 
				node children doWithIndex: [ :child :index | 
					index > 1 ifTrue: [ 
						str
							nextPut: $.;
							nextPut: Character cr ].
					str nextPutAll: (child printUsing: context) ] ] ].
	array := Array
		         with: (GPDigit value: -3)
		         with: (Array
				          with: (Array
						           with: (GPDigit value: 10)
						           with: (GPOperator operator: #-)
						           with: (GPDigit value: 6))
				          with: (GPOperator operator: #*)
				          with: (Array
						           with: (Array
								            with: (GPDigit value: 8)
								            with: (GPOperator operator: #*)
								            with: (GPDigit value: -3))
						           with: (GPOperator operator: #/)
						           with: (Array
								            with: (GPDigit value: 1)
								            with: (GPOperator operator: #+)
								            with: (GPDigit value: 2))))
		         with: (Array
				          with: (GPDigit value: 10)
				          with: (GPOperator operator: #-)
				          with: (GPDigit value: 8)).
	self
		assertCollection: (grammar evaluate: array)
		hasSameElements: #( -3 -32 2 ).
	self assert: (grammar ruleNameOf: array) equals: #expressions.
	self assert: (grammar nodeOf: array) print equals: '-3.
		((10-6)*((8*-3)/(1+2))).
		(10-8).'
]

{ #category : #tests }
GPGrammarOldTest >> test7 [

	"grammar 
	
	digit -> 1, 4, 3
	operator -> + | - | * | /
	operation -> #digit operator digit 
	expression -> #digit 
	expression -> operation
	expression -> expression operator expression
	comparisonSymbol -> < | > | <= | >= | == | =
	comparison -> expression comparisonSymbol expression 
	boolExpr -> true | false
	boolExpr -> comparison.
	block -> [ expressions ]
	condition -> boolExpr ifTrue: block ifFalse: block
	"

	| printBlock |
	printBlock := [ :node :context | 
	              String streamContents: [ :str | 
		              str
			              nextPut: $(;
			              nextPutAll: (node children first printUsing: context);
			              nextPutAll:
				              (node children second printUsing: context);
			              nextPutAll: (node children third printUsing: context);
			              nextPut: $) ] ].
	self
		addDigits: #( 1 2 3 4 5 6 7 );
		addOperators: #( #+ #- #* #/ );
		addRule: #operation
		withSequence: #( #digit #operator #digit )
		evaluationBlock: [ :node :context | 
			(node children first evaluateUsing: context)
				perform: (node children second evaluateUsing: context)
				with: (node children third evaluateUsing: context) ]
		and: printBlock;
		addRule: #expression
		withSequence: #( #digit )
		evaluationBlock: [ :node :context | 
			node children first evaluateUsing: context ]
		and: [ :node :context | node children first printUsing: context ];
		addRule: #expression
		withSequence: #( #operation )
		evaluationBlock: [ :node :context | 
			node children first evaluateUsing: context ]
		and: [ :node :context | node children first printUsing: context ];
		addRule: #expression
		withSequence: #( #expression #operator #expression )
		evaluationBlock: [ :node :context | 
			(node children first evaluateUsing: context)
				perform: (node children second evaluateUsing: context)
				with: (node children third evaluateUsing: context) ]
		and: printBlock.
	grammar
		at: #comparisonSymbol
		putValues: (#( #< #> #= #>= #<= #== ) collect: [ :s | 
				 GPComparisonSymbol symbol: s ])
		evaluationBlock: [ :node :context | node type symbol ]
		and: [ :node :context | node type symbol asString ].
	self
		addRule: #comparison
		withSequence: #( #expression #comparisonSymbol #expression )
		evaluationBlock: [ :node :context | 
			(node children first evaluateUsing: context)
				perform: (node children second evaluateUsing: context)
				with: (node children third evaluateUsing: context) ]
		and: printBlock.
	grammar
		at: #boolean
		putValues: (Array with: true with: false)
		evaluationBlock: [ :node :context | node type value ]
		and: [ :node :context | node type values asString ].
	self
		addRule: #boolExpr
		withSequence: #( #boolean )
		evaluationBlock: [ :node :context | node type value ]
		and: [ :node :context | node type value asString ];
		addRule: #boolExpr
		withSequence: #( #comparison )
		evaluationBlock: [ :node :context | 
			node children first evaluateUsing: context ]
		and: [ :node :context | node children first printUsing: context ].
	grammar
		at: #block
		putListOf: #expression
		evaluationBlock: [ :node :context | 
			(node children collect: [ :child | child evaluateUsing: context ])
				last ]
		and: [ :node :context | 
			String streamContents: [ :str | 
				str nextPutAll: '['.
				node children do: [ :child | 
					str nextPutAll: (child printUsing: context) ].
				str nextPutAll: ']' ] ].
	grammar
		at: #twoBlocks
		putListOf: #block
		evaluationBlock: [ :node :context | 
			node children collect: [ :child | child evaluateUsing: context ] ]
		and: [ :node :context | 
			(node children collect: [ :child | child printUsing: context ])
				asString ].
	self
		addRule: #condition
		withSequence: #( #boolExpr #twoBlocks )
		evaluationBlock: [ :node :context | 
			(node children first evaluateUsing: context)
				perform: #ifTrue:ifFalse:
				withArguments: (node children third evaluateUsing: context) ]
		and: [ :node :context | 
			String streamContents: [ :str | 
				str
					nextPutAll: (node children first printUsing: context);
					nextPutAll: #ifTrue:ifFalse:.
				str nextPutAll: (node children second printUsing: context) ] ].
	"	self
		assert: (grammar evaluate: (Array
					  with: (GPDigit value: 2)
					  with: (GPComparisonSymbol symbol: #<)
					  with: (GPDigit value: 5)))
		equals: true.
	self
		assert: (grammar evaluate: (Array
					  with: (Array
							   with: (GPDigit value: 2)
							   with: (GPOperator operator: #*)
							   with: (GPDigit value: 5))
					  with: (GPComparisonSymbol symbol: #<)
					  with: (GPDigit value: 5)))
		equals: false.
	self assert: (grammar evaluate: false) equals: false."
	self
		assert: (grammar evaluate: (Array with: true with: (Array
						   with: (Array
								    with: (Array
										     with: (GPDigit value: 2)
										     with: (GPOperator operator: #*)
										     with: (GPDigit value: 5))
								    with: (GPDigit value: 5))
						   with: (Array with: (GPDigit value: 3)))))
		equals: 5
]
