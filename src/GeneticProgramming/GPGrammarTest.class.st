Class {
	#name : #GPGrammarTest,
	#superclass : #TestCase,
	#instVars : [
		'grammar'
	],
	#category : #'GeneticProgramming-Tests'
}

{ #category : #adding }
GPGrammarTest >> addDigits: array [
	grammar 
		at: #digit putValues: (array collect: [:num | GPDigit value: num ])
			evaluationBlock: [:node :context | node type value ]
			and: [:node :context | node type value asString ] 
]

{ #category : #adding }
GPGrammarTest >> addOperators: array [
	grammar 
		at: #operator putValues: (array collect: [:op | GPOperator operator: op ])
		evaluationBlock: [:node :context | node type operator ]
		and: [ :node :context | node type operator ]
		
]

{ #category : #adding }
GPGrammarTest >> addRule: symbol withSequence: array evaluationBlock: evaluationBlock and: printBlock [
	grammar
		at: symbol put: array
		evaluationBlock: evaluationBlock
		and: printBlock.
]

{ #category : #running }
GPGrammarTest >> setUp [ 
	grammar := GPGrammar new
]

{ #category : #tests }
GPGrammarTest >> test1 [
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
GPGrammarTest >> test10 [
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
GPGrammarTest >> test2 [
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
GPGrammarTest >> test3 [
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
GPGrammarTest >> test4 [
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
GPGrammarTest >> test5 [
	| array printBlock |
	self addDigits: #(1 2 -3 6 8 10).
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
			with: (Array with: (GPDigit value: 10) 
							with: (GPOperator operator: #-) 
							with: (GPDigit value: 6))
			with: (GPOperator operator: #*)
			with: (Array with: (Array with: (GPDigit value: 8) 
									with: (GPOperator operator: #*) 
									with: (GPDigit value: -3)) 
							with: (GPOperator operator: #/) 
							with: (Array with: (GPDigit value: 1) 
									with: (GPOperator operator: #+) 
									with: (GPDigit value: 2))).
	self assert: (grammar evaluate: array) equals: -32.
	self assert: (grammar ruleNameOf: array) equals: #expression.
	self assert: (grammar nodeOf: array) print equals: '((10-6)*((8*-3)/(1+2)))'
]
