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
	self addDigits: #(1 3 5 6).
	self assert: (grammar evaluate: (GPDigit value: 1)) equals: 1.
	"self assert: (grammar rule: (GPDigit value: 1)) equals: #digit."
	self assert: (grammar evaluate: (GPDigit value: 8)) isNil.
	"self assert: (grammar rule: (GPDigit value: 8)) equals: #digit."
	self assert: (grammar evaluate: (GPDigit value: 5)) equals: 5.
	"self assert: (grammar rule: (GPDigit value: 5)) equals: #digit."
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
	self addDigits: #(1 2 3 4 5 60).
	grammar
		at: #digits putListOf: #digit
		evaluationBlock: [:node :context | (node children collect: [:child | child evaluateUsing: context ]) sum ]
		and: [:node :context | (node children collect: [ :child | child printUsing: context ]) asString ].
	self assert: (grammar evaluate: (GPDigit value: 1)) equals: 1.
	"self assert: (grammar rule: (GPDigit value: 1)) equals: #digit."
	self assert: (grammar evaluate: (GPDigit value: 8)) isNil.
	"self assert: (grammar rule: (GPDigit value: 8)) isNil."
	self assert: (grammar evaluate: (GPDigit value: 60)) equals: 60.
	"self assert: (grammar rule: (GPDigit value: 7)) equals: #digit."
	self assert: (grammar evaluate: (Array with: (GPDigit value: 1) with: (GPDigit value: 5))) equals: 6.
	"self assert: (grammar rule: (Array with: (GPDigit value: 1) with: (GPDigit value: 6))) equals: #digits."
	self assert: (grammar evaluate: (Array with: (GPDigit value: 1) with: (GPDigit value: 5) with: (GPDigit value: 60))) equals: 66.
	"self assert: (grammar rule: (Array with: (GPDigit value: 1) with: (GPDigit value: 5) with: (GPDigit value: 7))) equals: #digits."
	self assert: (grammar evaluate: (Array with: (GPDigit value: 1) with: (GPDigit value: 5) with: (GPDigit value: 7))) isNil.

]

{ #category : #tests }
GPGrammarTest >> test3 [
	self addDigits: #(1 3 6 8).
	self addOperators: #(#+ #- #* #/).
	self addRule: #operation
		withSequence: #(#digit #operator #digit) 
		evaluationBlock: [:node :context | 
			(node children first evaluateUsing: context) 
				perform: (node children second evaluateUsing: context) 
				with: (node children third evaluateUsing: context) ] 
		and: [ :node :context | 
			(node children first printUsing: context),
			(node children second printUsing: context),
			(node children third printUsing: context)].
	self assert: (grammar evaluate: (GPDigit value: 1)) equals: 1.
	self assert: (grammar evaluate: 
		(Array with: (GPDigit value: 1) 
				with: (GPOperator operator: #+) 
				with: (GPDigit value: 3))) equals: 4.
		"self assert: (grammar rule: 
		(Array with: (GPDigit value: 1) 
				with: (GPOperator operator: #+) 
				with: (GPDigit value: 3))) equals: #expression."
]

{ #category : #tests }
GPGrammarTest >> test4 [
	self addDigits: #(1 2 3 6 8 10).
	self addOperators: #(#+ #- #* #/).
	self addRule: #operation withSequence: #(#digit #operator #digit) 
		evaluationBlock: [:node :context | 
			(node children first evaluateUsing: context) 
				perform: (node children second evaluateUsing: context) 
				with: (node children third evaluateUsing: context) ] 
		and: [ :node :context | 
			(node children first printUsing: context),
			(node children second printUsing: context),
			(node children third printUsing: context)].
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
			and: [:node :context | 
				String streamContents: [:str | str 
					nextPut: $(;
					nextPutAll: (node children first printUsing: context);
					nextPutAll: (node children second printUsing: context);
					nextPutAll: (node children third printUsing: context);
					nextPut: $) ] ].
	self assert: (grammar evaluate: (GPDigit value: 1)) equals: 1.
	self assert: (grammar evaluate: 
		(Array 
			with: (Array with: (GPDigit value: 6) 
							with: (GPOperator operator: #+) 
							with: (GPDigit value: 3))
			with: (GPOperator operator: #*)
			with: (Array with: (GPDigit value: 8) 
							with: (GPOperator operator: #/) 
							with: (GPDigit value: 2)))) equals: 36.
]

{ #category : #tests }
GPGrammarTest >> test5 [
	self addDigits: #(1 2 -3 6 8 10).
	self addOperators: #(#+ #- #* #/).
	self addRule: #operation withSequence: #(#digit #operator #digit) 
		evaluationBlock: [:node :context | 
			(node children first evaluateUsing: context) 
				perform: (node children second evaluateUsing: context) 
				with: (node children third evaluateUsing: context) ] 
		and: [ :node :context | 
			(node children first printUsing: context),
			(node children second printUsing: context),
			(node children third printUsing: context)].
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
			and: [:node :context | 
				String streamContents: [:str | str 
					nextPut: $(;
					nextPutAll: (node children first printUsing: context);
					nextPutAll: (node children second printUsing: context);
					nextPutAll: (node children third printUsing: context);
					nextPut: $) ] ].
	self assert: (grammar evaluate: (GPDigit value: 1)) equals: 1.
	self assert: (grammar evaluate: 
		(Array 
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
									with: (GPDigit value: 2))))) equals: -32.
]
