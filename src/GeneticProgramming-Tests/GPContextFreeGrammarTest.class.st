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
	 grammar := GPContextFreeGrammar new.
	 GPRandom seed: 1
]

{ #category : #running }
GPContextFreeGrammarTest >> tearDown [

	 
	 GPRandom resetInstance.
	 super tearDown.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddLeafRuleOfClassWithValues [

	| ruleOption node options newNode |
	grammar addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 6).
	ruleOption := grammar ruleOptionOf: #F.
	self assert: ruleOption nodes size equals: 1.
	node := ruleOption getNodeWithOptionsAt: 1.
	options := node value.
	node := node key.
	self assert: node class equals: GPLeafNode.
	self assert: node type equals: RBLiteralNode.
	self assert: node children isEmpty.
	self assert: node nodeValue isNil.
	self assert: options size equals: 6.
	self assertCollection: options hasSameElements: #(1 2 3 4 5 6).
	newNode := (node evaluateUsing: grammar) valueWithPossibleArgs: (Array with: 0 with: Stack new).
	self deny: newNode nodeValue equals: node nodeValue.
	self assert: newNode print equals: '1'
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddLeafRuleWithValues [

	| node  ruleOption newNode |
	grammar addLeafRule: #F withValues: (1 to: 15) asArray.
	ruleOption := grammar ruleOptionOf: #F.
	self assert: ruleOption nodes size equals: 1.
	node := ruleOption getNodeAt: 1.
	newNode := (node evaluateUsing: grammar) valueWithPossibleArgs: (Array with: 0 with: Stack new).
	self deny: newNode nodeValue equals: node nodeValue.
	self assert: newNode print equals: '1'.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleOfClassWithSequence [

	| ruleOption node options newNode |
	grammar
		addRule: #Assignment ofClass: RBAssignmentNode withSequence: #( #Variable #Literal );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #b #c );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: #( 1 5 6 2 3 9 );
		depth: 1.
	ruleOption := grammar ruleOptionOf: #Assignment.

	self assert: ruleOption nodes size equals: 1.
	node := ruleOption getNodeWithOptionsAt: 1.
	options := node value.
	node := node key.
	self assert: node class equals: GPNode.
	self assert: node type equals: RBAssignmentNode.
	self assert: node children isNotEmpty.
	self assert: node children size equals: 2.
	self assertCollection: node children hasSameElements: #(#Variable #Literal).
	self assert: options isEmpty.
	newNode := (node evaluateUsing: grammar) valueWithPossibleArgs: (Array with: 0 with: Stack new).
	self assert: newNode numberOfNodes equals: 3.
	self deny: newNode nodeValue equals: node nodeValue.
	self assertCollection: (newNode children collect: #class) hasSameElements: (Array with: GPLeafNode with: GPLeafNode).
	self assertCollection: (newNode children collect: #id) hasSameElements: #(#Variable #Literal).
	self assertCollection: (newNode children collect: #nodeValue) hasSameElements: #(#a 1).
	self assertCollection: newNode print hasSameElements: '#(#Assignment #Variable #Literal)'.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleRedirectingTo [

	| ruleOption |
	grammar
		addRule: #E redirectingTo: #T.
	ruleOption := grammar ruleOptionOf: #E.
	self assert: ruleOption nodes isEmpty.
	self assert: ruleOption nodeOptions size equals: 1.
	self assertCollection: ruleOption nodeOptions hasSameElements: #(#T).
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleUsingBlock [

	| tree |
	grammar
		addRule: #E ofClass: RBBlockNode withSequence: #(#T);
		addLeafRule: #T ofClass: RBLiteralNode withValues: #(true false).
	tree := grammar expandTreeFrom: #E withDepth: 1.
	self assert: (RBParser parseExpression: '[true]') equals: tree ast
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleWithBlock [
	| tree |
	grammar 
		addRule: #E ofClass: RBMessageNode withSequence: #(#E #And #Block);
		addSelectorRule: #And withValues: #(#and:);
		addRule: #E redirectingTo: #F;
		addRule: #Block ofClass: RBBlockNode withSequence: #(#F);
		addLeafRule: #F ofClass: RBLiteralNode withValues: #(true false).
	tree := grammar expandTreeFrom: #E withDepth: 3.
	self assert: (RBParser parseExpression: '(false and: [true]) and: [false]') equals: tree ast.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleWithCollectionOptionsOfSize [

	| ruleOption node newNode |
	grammar
		addLeafRule: #number
		ofClass: RBLiteralNode
		withValues: #( 1 2 3 4 5 6 );
		addRule: #numbers withCollectionOptions: #( #number ) ofSize: 3;
		depth: 1.
	ruleOption := grammar ruleOptionOf: #numbers.
	self assert: ruleOption nodes size equals: 1.
	node := ruleOption getNodeAt: 1.
	self assert: node class equals: GPCollectionNode.
	self assert: node children isEmpty.
	newNode := (node evaluateUsing: grammar) valueWithPossibleArgs: (Array with: 0 with: Stack new).
	self deny: newNode nodeValue equals: node nodeValue.
	self assert: newNode numberOfNodes equals: 4.
	self deny: newNode numberOfNodes equals: node numberOfNodes
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleWithSequence [
	| tree ast |
	GPRandom seed: 98345.
	grammar 
		addRule: #E ofClass: RBSequenceNode withSequence: #(#F #F);
		"addRule: #E redirectingTo: #F;"
		addLeafRule: #F withValues: #(true false).
	tree := grammar expandTreeFrom: #E withDepth: 1.
	self assert: tree numberOfNodes equals: 3.
	ast := tree ast.
	"self assertCollection: (tree statements collect: #evaluate) hasSameElements: #(true false)."
	self assertCollection: ast evaluate hasSameElements: #(true false)
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddSelectorRuleWithValues [
	| ruleOption node newNode options |
	grammar addSelectorRule: #Add withValues: #(#+ #-).
	ruleOption := grammar ruleOptionOf: #Add.
	self assert: ruleOption nodes size equals: 1.
	node := ruleOption getNodeWithOptionsAt: 1.
	options := node value.
	node := node key.
	self assert: node class equals: GPNode.
	self assert: node children isEmpty.
	self assert: node nodeValue isNil.
	self assert: options size equals: 2.
	self assertCollection: options hasSameElements: #(#+ #-).
	newNode := node evaluateUsing: grammar.
	self deny: newNode nodeValue equals: node nodeValue.
	self assert: newNode print equals: #+.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testDictionaryOfOptionWithWeights [

	| config dict |
	config := GPConfiguration new.
	config forRule: #E putWeights: #( 10 1 1 ).
	grammar
		addRule: #E
		ofClass: RBMessageNode
		withSequence: #( #E #AddOp #E ).
	grammar addRule: #E redirectingTo: #Number.
	grammar addRule: #E redirectingTo: #Variable.
	grammar configuration: config.
	dict := grammar dictionaryOfOptionsWithWeights: #E.
	self
		assertCollection: dict associations
		hasSameElements: (Array with: 1 -> 10 with: 2 -> 1 with: 3 -> 1)
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpand [

	| result |
	GPRandom seed: 11324 "113541" "113547".
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	result := grammar expand.
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 13.
	"self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
		#( #E #T #F #MulOp #F #AddOp #T #T #F #MulOp #F #MulOp #F )."
	self assert: result ast evaluate equals: -33 / 10
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandAny [

	| result |
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	result := (1 to: 10) collect: [:n | grammar expandAny ].
	self assertCollection: (result collect: #id) includesAny: #(#MulOp #AddOp).
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandFrom [

	 | result |
	 GPRandom seed: 113542.
	 grammar
		 addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		 addRule: #E withSequence: #( #E #AddOp #T );
		 addRule: #E redirectingTo: #T;
		 addSelectorRule: #MulOp withValues: #( #mul: #div: );
		 addRule: #T withSequence: #( #T #MulOp #F );
		 addRule: #T redirectingTo: #F;
		 addLeafRule: #F
		 withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	 result := grammar expandTreeFrom: #T withDepth: 3.
	 "result -> 			T
					  T  MulOp	F
				 F MulOp F "
	 self assert: result id equals: #T.
	 self assert: result numberOfNodes equals: 7.
	 self
		 assertCollection: (result withAllChildren collect: #id)
		 hasSameElements: #( #T #T #T #F #MulOp #F #MulOp #F ).
	 self assert: result nodeValue equals: 1/7
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandFromWithLogicExample [

	| result |
	GPRandom seed: 113542.
	grammar
		addSelectorRule: #LogOp withValues: #( #and: #or: );
		addRule: #E withSequence: #( #E #LogOp #T );
		addRule: #E redirectingTo: #T;
		addLeafRule: #T
		withValues:
			(Array with: (GPBool value: true) with: (GPBool value: false)).
	result := grammar expandTreeFrom: #E.
	"result -> 			E
					 E   and:   T
				 T and: T
				    "
	self assert: result numberOfNodes equals: 7.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #E #E #E #T #LogOp #T #LogOp #T ).
	self assert: result nodeValue logicValue equals: false
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodes [

	| tree |
	"Assign -> Variable Value
	Variable -> #a | #v | #m
	Value -> Literal | Message
	Message -> Receiver Selector Args
	Literal -> 1 .. 10 
	Receiver -> Literal 
	Selector -> #+ | #- 
	Args -> #(Literal)"
	GPRandom seed: 78653.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ) ofSize: 1.
	tree := grammar expandTreeFrom: #Assignment withDepth: 2.
	self assert: tree id equals: #Assignment.
	self assert: tree numberOfNodes equals: 7.
	self
		assertCollection: (tree withAllChildren collect: #id)
		hasSameElements:
		#( #Assignment #Variable #Message #Literal #Selector #Args #Literal ).
	"result := result value.
	self assert: result equals: (RBAssignmentNode
			 variable: (RBVariableNode named: #m)
			 value: (RBMessageNode
					  receiver: (RBLiteralNode value: 6)
					  selector: #+
					  arguments: (Array with: (RBLiteralNode value: 1)))).
	self assert: result evaluate equals: 7"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursively [

	| result |
	GPRandom seed: 78653.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 1.
	result := grammar expandTreeFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 43.
	"result := result value.
	self assert: result evaluate equals: 10"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursively2 [

	| result |
	GPRandom seed: 78662.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 1.
	result := grammar expandTreeFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 7.
	"result := result value.
	self assert: result evaluate equals: 63"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursivelyWithColorExample [

	| result |
	GPRandom seed: 78651.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues:
			(#( #blue #red #yellow #black #green #pink ) collect: [ :s | 
					 Color perform: s ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addSelectorRule: #Selector withValues: #( #lighter #asColor );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 1.
	result := grammar expandTreeFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 383.
	"result := result value.
	self assert: result evaluate equals: Color green lighter"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursivelyWithWeigthsAndDepth [

	"| result configuration ast |
	random seed: 78653.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 3 10 ) forRule: #Value;
		                 addOptionWeights: #( 7 2 ) forRule: #Selector;
		                 addOptionWeights: #( 7 6 2 8 1 3 6 4 8 1 )
		                 forRule: #Literal;
		                 depth: 20.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Message.
	self assert: result numberOfNodes equals: 58.
	ast := grammar generateASTFrom: result.
	self assert: ast equals: -14"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesWithWeights [

	| result configuration |
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector );
		addRule: #Receiver redirectingTo: #Literal;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ) ofSize: 1.
	configuration := GPConfiguration new
		                 forRule: #Value putWeights: #( 4 10 );
		                 forRule: #Selector putWeights: #( 7 6 );
		                 forRule: #Literal
		                 putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	result := grammar expandFrom: #Assignment given: configuration.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 3.
	self assert: result ast formattedCode equals: 'm := 9'
	"result := result value.
	self assert: result equals: (RBVariableNode named: #a)"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesWithWeights2 [

	| result configuration |
	GPRandom seed: 78652.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ) ofSize: 1.
	configuration := GPConfiguration new
		                 forRule: #Value putWeights: #( 4 10 );
		                 forRule: #Selector putWeights: #( 7 6 );
		                 forRule: #Literal
		                 putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Message.
	self assert: result numberOfNodes equals: 5
	"result := result value.
	self assert: result evaluate equals: 1"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnFooExample [

	"| result configuration |
	random seed: 1.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable withValues: (Array
				 with: (RBVariableNode named: #a)
				 with: (RBVariableNode named: #v)
				 with: (RBVariableNode named: #m));
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		withValues: (1 to: 5) asArray , ((1 to: 10) collect: [ :n | 
						 GPFoo new
							 foo: n;
							 yourself ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addMessageRule: #Selector withValues: #( #foo: #bar: #+ #- #* );
		addRule: #Args withCollectionOptions: #( #Value ).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 3 10 ) forRule: #Value;
		                 addOptionWeights: #( 7 2 ) forRule: #Selector;
		                 addOptionWeights: #( 7 6 2 8 1 3 6 4 8 1 )
		                 forRule: #Literal;
		                 depth: 10.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 3
	result := grammar replaceValuesOf: result.
	self assert: result evaluate equals: -14"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnMethodNode [
	grammar
		addRule: #Method
		ofClass: RBMethodNode
		withSequence: #( #Selector #Body #Arguments );
		addLeafRule: #Selector withValues: #( #add );
		addRule: #Body redirectingTo: #Sequence;
		addRule: #Sequence
		ofClass: RBSequenceNode
		withSequence: #( #Temporaries #Statements );
		addRule: #Temporaries withCollectionOptions: #( #Variable ) ofSize: 1;
		addRule: #Statements
		withCollectionOptions: #( #Assignment #Message #Return ) ofSize: 1;
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Arguments );
		addRule: #Return ofClass: RBReturnNode withSequence: #( #Value );
		addRule: #Receiver redirectingTo: #Value;
		addSelectorRule: #Selector withValues: #( #foo: #bar: #+ #- #* );
		addRule: #Arguments withOptions: #( #Value );
		addRule: #Value
		withOptions: #( #Message #Variable #Literal #Block );
		addRule: #Block
		ofClass: RBBlockNode
		withSequence: #( #Arguments #Body );
		addRule: #Colons withCollectionOptions: #(  ) ofSize: 0;
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #(  );
		"addLeafRule: #Variable withValues: (Array
				 with: (RBVariableNode named: #a)
				 with: (RBVariableNode named: #v)
				 with: (RBVariableNode named: #m));"
		addLeafRule: #Literal
		withValues: (1 to: 5) asArray , ((1 to: 10) collect: [ :n | 
						 GPFoo new
							 foo: n;
							 yourself ])
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnMethodNodeOfRoassal3 [

	"| result configuration |
	random seed: 1.
	grammar
		addRule: #Method
		ofClass: RBMethodNode
		withSequence: #( #MethodSelector #Body #Arguments );
		addLeafRule: #MethodSelector withValues: #( #numberOfShapes );
		addRule: #Body redirectingTo: #Sequence;
		addRule: #Sequence
		ofClass: RBSequenceNode
		withSequence: #( #Temporaries #Statements );
		addRule: #Temporaries withCollectionOptions: #( #Variable );
		addRule: #Statements
		withCollectionOptions: #( #Assignment #Message #Return );
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Arguments );
		addRule: #Return ofClass: RBReturnNode withSequence: #( #Value );
		addRule: #Receiver redirectingTo: #Value;
		addMessageRule: #Selector withValues: #( #size );
		addRule: #Arguments withCollectionOptions: #( #Value );
		addRule: #Value withOptions: #( #Message #Variable #Literal );
		addRule: #Block
		ofClass: RBBlockNode
		withSequence: #( #Arguments #Body );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #shapes );
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: #(  )." "#Message" "#Block"
	"weights "
	"configuration := GPASTConfiguration new 
		addOptionWeights: #( 19 )
		forRule: #Method;
		depth: 9."
	"expand nodes of grammar"
	"result := grammar expandFrom: #Method given: configuration.
	self assert: result id equals: #Method"
	"self assert: result numberOfNodes equals: 12."
	"result := grammar replaceValuesOf: result.
	self assert: (RSCanvas new perform: result selector) equals: 0"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnMethodNodeOfRoassal3WithDepth [

	| result configuration |
	GPRandom seed: 100.
	"grammar"
	grammar
		addRule: #Statements
		withCollectionOptions: #( #Assignment #Message #Return )
		ofSize: 1;
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Arguments );
		addRule: #Return ofClass: RBReturnNode withSequence: #( #Value );
		addRule: #Receiver redirectingTo: #Value;
		addSelectorRule: #Selector withValues: #( #size );
		addRule: #Arguments withCollectionOptions: #( #Value ) ofSize: 1;
		addRule: #Value
		withOptions: #( #Message #Variable #Literal #Block );
		addRule: #Block
		ofClass: RBBlockNode
		withSequence: #( #Arguments #Body );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #shapes );
		addRule: #Body redirectingTo: #Sequence;
		addRule: #Sequence
		ofClass: RBSequenceNode
		withSequence: #( #Temporaries );
		addRule: #Temporaries
		withCollectionOptions: #( #Variable )
		ofSize: 1;
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: #( 1 ). "#Statements"
	configuration := GPConfiguration new
		                 forRule: #Value
		                 putWeights: #( 10 2 3 ). "1" ";
		                 depth: 7"
	"addOptionWeights: #( 19 ) forRule: #Method;"
	"expand nodes of grammar"
	result := grammar expandFrom: #Statements given: configuration
	"self assert: result id equals: #Method."
	"self assert: result numberOfNodes equals: 12."
	"result := result value.
	self assert: (RSCanvas new perform: result selector) equals: 0"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandReplacingFrom [

	| result |
	"Assign -> Variable Value
	Variable -> #a | #v | #m
	Value -> Literal | Message
	Message -> Receiver Selector Args
	Literal -> 1 .. 10 
	Receiver -> Literal 
	Selector -> #+ | #- 
	Args -> #(Literal)"
	GPRandom seed: 78653.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ) ofSize: 1.
	result := grammar expandTreeFrom: #Assignment.
	"result -> 			 		Ass
						  	Var  			 Mess
							m		  Lit Sel  Args
									  6    +   Lit
										         1        
				           "
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 7.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
		#( #Assignment #Variable #Message #Literal #Selector #Args #Literal)
	"result := result value
	
	result := grammar replaceValuesOf: result
	self assert: result equals: (RBAssignmentNode
			 variable: (RBVariableNode named: #m)
			 value: (RBMessageNode
					  receiver: (RBLiteralNode value: 6)
					  selector: #+
					  arguments: (Array with: (RBLiteralNode value: 1)))).
	self assert: result evaluate equals: 7"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandReplacingFromLiteralNode [

	| result |
	GPRandom seed: 78652.
	grammar
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray.
	result := grammar expandTreeFrom: #Literal.
	"result -> 			 		Lit
										2    
				           "
	self assert: result id equals: #Literal.
	self assert: result numberOfNodes equals: 1.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #Literal )
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandTree [
	| node depth |
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #Mul withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #Mul #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10);
		addRule: #F redirectingTo: #E.
	node := grammar expandTree: #E.
	depth := grammar depth.
	self assert: (node allLeaves detect: [ :n | n depth == depth ] ifFound: [ true ] ifNone: [ false ] )
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandTreeFromWithDepth [
	| tree |
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #T );
		addRule: #E redirectingTo: #T;
		addLeafRule: #T ofClass: RBLiteralNode withValues: (1 to: 10).
	tree := grammar expandTreeFrom: #E withDepth: 4.
	self assert: tree numberOfNodes equals: 10.
	self assert: tree print equals: '#(#E #E #E #T #Add #T #Add #T #Add #T)'.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandTreeFromWithETFGrammar [

	| ruleOption node options newNode |
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #Mul withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #Mul #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10);
		addRule: #F redirectingTo: #E.
	ruleOption := grammar expandTreeFrom: #E.

	self assert: ruleOption nodes size equals: 1.
	node := ruleOption getNodeWithOptionsAt: 1.
	options := node value.
	node := node key.
	self assert: node class equals: GPNode.
	self assert: node type equals: RBAssignmentNode.
	self assert: node children isNotEmpty.
	self assert: node children size equals: 2.
	self assertCollection: node children hasSameElements: #(#Variable #Literal).
	self assert: options isEmpty.
	newNode := node evaluateUsing: grammar.
	self assert: newNode numberOfNodes equals: 3.
	self deny: newNode nodeValue equals: node nodeValue.
	self assertCollection: (newNode children collect: #class) hasSameElements: (Array with: GPNode with: GPNode with: GPNode).
	self assertCollection: (newNode children collect: #id) hasSameElements: #(#Variable #Literal).
	self assertCollection: (newNode children collect: #nodeValue) hasSameElements: #(#a 6).
	self assertCollection: newNode print hasSameElements: '#(#Assignment #Variable #Literal)'.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandTreeWithConfiguration [
	| tree configuration |
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #T );
		addRule: #E redirectingTo: #T;
		addLeafRule: #T ofClass: RBLiteralNode withValues: (1 to: 5).
	configuration := GPConfiguration new
		forRule: #E putWeights: #(2 8);
		forRule: #T putWeights: #(2 1 2 1 8).
	grammar configuration: configuration.
	tree := grammar expandTreeFrom: #E.
	self assert: tree print equals: 'T'.
	self assert: tree withAllChildren size equals: 1.
	self assert: tree nodeValue equals: 5
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsing [

	| result configuration |
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	result := grammar expandUsing: configuration.
	"result -> 			F  "
	self assert: result id equals: #F.
	self assert: result numberOfNodes equals: 1.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #F ).
	self assert: result ast evaluate value equals: 4
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingAnotherSeed [

	| result configuration |
	GPRandom seed: 78652.
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	result := grammar expandUsing: configuration.
	self assert: result id equals: #T.
	self assert: result numberOfNodes equals: 28
	"self
		assert: (result evaluate: grammar given: configuration) value
		equals: 2/9"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingAnotherSeed2 [

	| result configuration |
	GPRandom seed: 19683.
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	result := grammar expandUsing: configuration.
	self assert: result id equals: #T.
	self assert: result numberOfNodes equals: 31
	"self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #T #T #T #F #MulOp #F #MulOp #F )."
	"self
		assert: (result evaluate: grammar given: configuration) value
		equals: 648000"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingLongerSeed [

	| result configuration |
	GPRandom seed: 689684.
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	result := grammar expandUsing: configuration
	"self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 25.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: -245"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingWeightsAndLongDepth [

	| result configuration |
	GPRandom seed: 1.
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 );
		                 depth: 5.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #T.
	self assert: result numberOfNodes equals: 13
	"self
		assert: (result evaluate: grammar given: configuration) value
		equals: 4480"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingWithoutWeightsOfRules [

	| result configuration |
	GPRandom seed: 1.
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPConfiguration new
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	result := grammar expandUsing: configuration.
	self assert: result id equals: #T.
	self assert: result numberOfNodes equals: 7
	"self
		assert: (result evaluate: grammar given: configuration) value
		equals: 20/7"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandWithWeightsAndDepth [

	| result configuration |
	GPRandom seed: 68921.
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 );
		                 depth: 1.
	result := grammar expandUsing: configuration.
	"result -> 		F  "
	self assert: result id equals: #F.
	self assert: result numberOfNodes equals: 1.
	self assert: result ast evaluate value equals: 5
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandWithWeightsAndLongerDepth [

	| result configuration |
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 );
		                 depth: 10.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #T.
	self assert: result numberOfNodes equals: 28
	"self
		assert: (result evaluate: grammar given: configuration) value
		equals: 4032"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateAST [

	| result |
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Literal );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #b #c );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: #( 1 5 6 2 3 9 ).
	result := grammar expandTreeFrom: #Assignment.
	self assert: result numberOfNodes equals: 3.
	self assert: result ast equals: (RBParser parseExpression: 'c := 6')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfLiteral [

	| result |
	grammar
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: #( 1 5 6 2 3 9 ).
	result := grammar expand.
	self assert: result numberOfNodes equals: 1.
	self assert: result ast equals: (RBParser parseExpression: '1')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfMessage [

	| result |
	grammar
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message #Variable );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 1.
	result := grammar expandTreeFrom: #Message.
	self assert: result numberOfNodes equals: 5.
	self assert: result ast equals: (RBParser parseExpression: '6 + m' "'8 + (7 - v)'")
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfMessage2 [

	| result |
	GPRandom seed: 45226.
	grammar
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message #Variable );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 1.
	result := grammar expandTreeFrom: #Message.
	self assert: result numberOfNodes equals: 9.
	self assert: result ast equals: (RBParser parseExpression: '10 - (3 - 5)' "'1 - v'")
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfMessage3 [

	| result |
	GPRandom seed: 613216.
	grammar
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message #Variable );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 1.
	result := grammar expandTreeFrom: #Message.
	self assert: result numberOfNodes equals: 5.
	self
		assert: result ast
		equals: (RBParser parseExpression: '4 + v' "'3 - (8 + (3 + (7 - a)))'")
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfMessage4 [

	| result ast |
	GPRandom seed: 5.
	grammar
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message #Variable );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray;
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addSelectorRule: #Selector withValues: #( #foo:bar: );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 2.
	result := grammar expandTreeFrom: #Message.
	self assert: result numberOfNodes equals: 6.
	ast := result ast
	"self assert: ast equals: (RBParser parseExpression: '8 + (7 - v)')"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfMessage5 [

	| result |
	GPRandom seed: 5.
	grammar
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message #Variable );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addSelectorRule: #Selector withValues: #( #foo:bar: );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 2.
	result := grammar expandTreeFrom: #Message.
	self assert: result numberOfNodes equals: 6.
	result ast
	"self assert: ast equals: (RBParser parseExpression: '8 + (7 - v)')"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfRoassal3 [

	| result configuration |
	GPRandom seed: 100.
	"grammar"
	grammar
		addRule: #Statements
		withCollectionOptions: #( #Assignment #Message )
		ofSize: 1;
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Arguments );
		"addRule: #Return ofClass: RBReturnNode withSequence: #( #Value );"
		addRule: #Receiver
		redirectingTo: #Value;
		addSelectorRule: #Selector withValues: #( #size );
		addRule: #Arguments withCollectionOptions: #( #Value ) ofSize: 0;
		addRule: #Value withOptions: #( #Message #Variable );
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #shapes ). "#Return" ";
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: #( 1 )" "#Block"
	"addRule: #Block
		ofClass: RBBlockNode
		withSequence: #( #Arguments #Body );
		addRule: #Body redirectingTo: #Sequence;
		addRule: #Sequence
		ofClass: RBSequenceNode
		withSequence: #( #Temporaries );
		addRule: #Temporaries withCollectionOptions: #( #Variable )" "#Statements"
	configuration := GPConfiguration new
		                 forRule: #Value putWeights: #( 10 2 );
		                 depth: 5.
	result := grammar expandFrom: #Statements given: configuration.
	self
		assert: result ast
		equals: (Array with: (RBParser parseExpression: 'shapes size'))
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGeneratingManyTrees [

	| config asts |
	config := GPConfiguration new.
	config forRule: #E putWeights: #( 100 10 10 ).
	asts := (1 to: 3) collect: [ :i | 
		        | tree ast |
		        grammar := GPContextFreeGrammar new.
		        grammar
			        addRule: #E
			        ofClass: RBMessageNode
			        withSequence: #( #E #AddOp #E ).
		        grammar addRule: #E redirectingTo: #Number.
		        grammar addRule: #E redirectingTo: #Variable.

		        grammar addSelectorRule: #AddOp withValues: #( #+ ).
		        grammar
			        addLeafRule: #Number
			        ofClass: RBLiteralNode
			        withValues: (-30 to: 30).
		        grammar
			        addLeafRule: #Variable
			        ofClass: RBVariableNode
			        withValues: #( 'x' ).

		        tree := grammar expandFrom: #E given: config.
		        ast := tree ast ]
]

{ #category : #tests }
GPContextFreeGrammarTest >> testLimitNumberOfIterations [

	| config tree |
	GPRandom seed: 10.
	config := GPConfiguration new.
	config forRule: #E putWeights: #( 10 1 1 ).
	grammar
		addRule: #E
		ofClass: RBMessageNode
		withSequence: #( #E #AddOp #E ).
	grammar addRule: #E redirectingTo: #Number.
	grammar addRule: #E redirectingTo: #Variable.
	grammar addSelectorRule: #AddOp withValues: #( #+ ).
	grammar
		addLeafRule: #Number
		ofClass: RBLiteralNode
		withValues: (-5 to: 5).
	grammar
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( 'x' ).
	tree := grammar expandFrom: #E given: config.
	tree ast
]

{ #category : #tests }
GPContextFreeGrammarTest >> testRandomOptionsOf [

	| configuration |
	grammar
		addRule: #Stms
		withCollectionOptions: #( #Assignment #Message )
		ofSize: 1;
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
	configuration := GPConfiguration new
		                 forRule: #Value putWeights: #( 10 2 );
		                 depth: 2.
	grammar configuration: configuration.
	self
		assertCollection: (grammar randomOptionsOf: #Value) asArray
		equals: #( #Variable #Message )
]

{ #category : #tests }
GPContextFreeGrammarTest >> testSimpleExample [

	| tree |
	GPRandom seed: 342423.
	grammar
		addRule: #E
		ofClass: RBMessageNode
		withSequence: #( #E #AddOp #E ).
	grammar addRule: #E redirectingTo: #Number.
	grammar addSelectorRule: #AddOp withValues: #( #+ ).
	grammar
		addLeafRule: #Number
		ofClass: RBLiteralNode
		withValues: (-30 to: 30).
	tree := grammar expandTreeFrom: #E withDepth: 10.
	self assert: tree numberOfNodes equals: 52.
	self assert: tree ast evaluate equals: 89
]

{ #category : #tests }
GPContextFreeGrammarTest >> testSimpleExample2 [

	| tree configuration |
	GPRandom seed: 689669.
	grammar
		addSelectorRule: #AddOp withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10).
	configuration := GPConfiguration new
		                 forRule: #E putWeight: 8;
		                 forRule: #T putWeight: 5;
		                 forRule: #F putWeight: 4;
		                 forRule: #E putWeights: #( 8 5 );
		                 forRule: #T putWeights: #( 6 3 );
		                 forRule: #AddOp putWeights: #( 6 4 );
		                 forRule: #MulOp putWeights: #( 6 3 );
		                 forRule: #F putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	tree := grammar expandUsing: configuration.
	self assert: tree id equals: #T.
	self assert: tree numberOfNodes equals: 13.
	tree ast
	"self assert: ast evaluate equals: 20"
]
