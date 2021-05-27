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
	 grammar := GPContextFreeGrammar new seed: 1
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
GPContextFreeGrammarTest >> testAddRuleOfClassWithSequenceAndFullMethod [

	| tree |
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #E );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #Mul withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #Mul #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10);
		addRule: #F redirectingTo: #E;
		methodName: #full.
	tree := grammar expandTree: #E withDepth: 3.
	self assert: tree numberOfNodes equals: 4.
	self assertCollection: (tree withAllChildren collect: #id) hasSameElements: #(#E #F #Add #F).
	self assert: (tree allLeaves reject: #isSelectorNode thenCollect: #depth) asSet size equals: 1.
	self assert: (tree allLeaves reject: #isSelectorNode thenCollect: #depth) first equals: 3.
	self assert: tree ast equals: (RBParser parseExpression: '6 - 1')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleOfClassWithSequenceAndGrowMethod [

	| tree |
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #E );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #Mul withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #Mul #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10);
		addRule: #F redirectingTo: #E;
		methodName: #grow.
	tree := grammar expandTree: #E withDepth: 3.
	self assert: tree numberOfNodes equals: 4.
	self assertCollection: (tree withAllChildren collect: #id) hasSameElements: #(#T #F #Mul #F).
	self assert: (tree allLeaves reject: #isSelectorNode thenCollect: #depth) asSet size >= 1.
	self assert: tree ast equals: (RBParser parseExpression: '1 / 10')
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
	tree := grammar expandTree: #E withDepth: 1.
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
	tree := grammar expandTree: #E withDepth: 3.
	self assert: (RBParser parseExpression: '(false and: [false]) and: [false]') equals: tree ast.
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
	"| tree ast |
	GPRandom seed: 98345.
	grammar 
		addRule: #E ofClass: RBSequenceNode withSequence: #(#F #F);
		addLeafRule: #F withValues: #(true false).
	tree := grammar expandTree: #E withDepth: 1.
	self assert: tree numberOfNodes equals: 3.
	ast := tree ast.
	self assertCollection: ast evaluate hasSameElements: #(true false)"
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
	self assert: node class equals: GPSelectorNode.
	self assert: node children isEmpty.
	self assert: node nodeValue isNil.
	self assert: options size equals: 2.
	self assertCollection: options hasSameElements: #(#+ #-).
	newNode := (node evaluateUsing: grammar) valueWithPossibleArgs: (Array with: 0 with: Stack new).
	self deny: newNode nodeValue equals: node nodeValue.
	self assert: newNode print equals: #+.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpand [

	| tree |
	grammar
		seed: 11324;
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #Mul withValues: #( #* #/ );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #Mul #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode withValues: (1 to: 10).
	tree := grammar expandTree: #T.
	self assert: tree id equals: #T.
	self assert: tree numberOfNodes equals: 4.
	self assert: tree ast evaluate equals: 40
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandFrom [

	 | tree |
	 grammar
		seed: 113542;
		 addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		 addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #T );
		 addRule: #E redirectingTo: #T;
		 addSelectorRule: #MulOp withValues: #( #mul: #div: );
		 addRule: #T ofClass: RBMessageNode withSequence: #( #T #MulOp #F );
		 addRule: #T redirectingTo: #F;
		 addLeafRule: #F ofClass: RBLiteralNode withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	 tree := grammar expandTree: #T withDepth: 3.
	 self assert: tree id equals: #T.
	 self assert: tree numberOfNodes equals: 7.
	 self
		 assertCollection: (tree withAllChildren collect: #id)
		 hasSameElements: #( #T #T #T #F #MulOp #F #MulOp #F ).
	 self assert: tree ast evaluate value equals: 1/70
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandFromWithLogicExample [

	| tree |
	grammar
		seed: 113542;
		addSelectorRule: #LogOp withValues: #( #and: #or: );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #LogOp #T );
		addRule: #E redirectingTo: #T;
		addLeafRule: #T ofClass: RBLiteralNode
		withValues:
			(Array with: (GPBool value: true) with: (GPBool value: false)).
	tree := grammar expandTree: #E withDepth: 3.
	self assert: tree numberOfNodes equals: 7.
	self
		assertCollection: (tree withAllChildren collect: #id)
		hasSameElements: #( #E #E #E #T #LogOp #T #LogOp #T ).
	self assert: tree ast evaluate logicValue equals: true
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandGiven [

	| tree configuration |
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
	tree := grammar expandGiven: configuration.
	self assert: tree id equals: #F.
	self assert: tree numberOfNodes equals: 1.
	self
		assertCollection: (tree withAllChildren collect: #id)
		hasSameElements: #( #F ).
	self assert: tree ast value equals: 3
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodes [

	| tree |
	grammar
		seed: 78653;
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
	tree := grammar expandTree: #Assignment withDepth: 2.
	self assert: tree id equals: #Assignment.
	self assert: tree numberOfNodes equals: 3.
	self
		assertCollection: (tree withAllChildren collect: #id)
		hasSameElements: #( #Assignment #Variable #Literal ).
	self assert: tree ast equals: (RBParser parseExpression: 'v := 3')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursively [

	| tree |
	grammar
		seed: 78653;
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
	tree := grammar expandTree: #Assignment withDepth: 7.
	self assert: tree id equals: #Assignment.
	self assert: tree numberOfNodes equals: 7.
	"result := result value.
	self assert: result evaluate equals: 10"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursivelyWithWeigthsAndDepth [

	| tree configuration |
	grammar
		seed: 78653;
		addRule: #Assignment ofClass: RBAssignmentNode withSequence: #( #Variable #Value );
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: (1 to: 10);
		addRule: #Message ofClass: RBMessageNode withSequence: #( #Value #Selector #Args );
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ) ofSize: 1.
	configuration := GPConfiguration new
		                 forRule: #Value putWeights: #( 3 10 );
		                 forRule: #Selector putWeights: #( 7 2 );
		                 forRule: #Literal putWeights: #( 7 6 2 8 1 3 6 4 8 1 );
		                 depth: 20.
	tree := grammar expandTree: #Message given: configuration.
	self assert: tree id equals: #Message.
	self assert: tree numberOfNodes equals: 205.
	self assert: tree ast evaluate equals: 52
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesWithWeights [

	| tree configuration |
	grammar
		addRule: #Assignment ofClass: RBAssignmentNode withSequence: #( #Variable #Value );
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #( #a #v #m );
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: (1 to: 10) asArray;
		addRule: #Message ofClass: RBMessageNode withSequence: #(#Literal #Selector #Args);
		addSelectorRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ) ofSize: 1.
	configuration := GPConfiguration new
		                 forRule: #Value putWeights: #( 4 10 );
		                 forRule: #Selector putWeights: #( 7 6 );
		                 forRule: #Literal
		                 putWeights: #( 4 6 3 8 9 7 7 2 6 5 ).
	tree := grammar expandTree: #Assignment given: configuration.
	self assert: tree id equals: #Assignment.
	self assert: tree numberOfNodes equals: 7.
	self assert: tree ast formattedCode equals: 'a := 9 + 7'
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
GPContextFreeGrammarTest >> testExpandTree [

	| tree children |
	grammar
		seed: 78652;
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
	tree := grammar expandTree: #Assignment.
	self assert: tree id equals: #Assignment.
	self assert: tree numberOfNodes equals: 7.
	self assert: tree depth equals: 0.
	children := tree children.
	self assert: children size equals: 2.
	self assert: children first depth equals: 1.
	self assert: children second depth equals: 2. 
	self assert: children second id equals: #Message.
	children := children second children.
	self assert: children size equals: 3.
	self assertCollection: (children allButFirst collect: #depth) asSet hasSameElements: #(3). 
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandTree2 [
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
GPContextFreeGrammarTest >> testExpandTreeFromLiteralNode [

	| tree |
	grammar
		seed: 78652;
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray.
	tree := grammar expandTree: #Literal.
	self assert: tree id equals: #Literal.
	self assert: tree numberOfNodes equals: 1.
	self
		assertCollection: (tree withAllChildren collect: #id)
		hasSameElements: #( #Literal ).
	self assert: tree nodeValue equals: 8.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandTreeFromWithDepth [
	| tree |
	grammar
		addSelectorRule: #Add withValues: #( #+ #- );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #Add #T );
		addRule: #E redirectingTo: #T;
		addLeafRule: #T ofClass: RBLiteralNode withValues: (1 to: 10).
	tree := grammar expandTree: #E withDepth: 4.
	self assert: tree numberOfNodes equals: 10.
	self assertCollection: (tree withAllChildren collect: #id) hasSameElements: #(#E #E #E #T #Add #T #Add #T #Add #T).
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
		addRule: #F redirectingTo: #E;
		depth: 3.
	ruleOption := grammar ruleOptionOf: #E.

	self assert: ruleOption nodes size equals: 1.
	node := ruleOption getNodeWithOptionsAt: 1.
	options := node value.
	node := node key.
	self assert: node class equals: GPNode.
	self assert: node type equals: RBMessageNode.
	self assert: node children isNotEmpty.
	self assert: node children size equals: 3.
	self assertCollection: node children hasSameElements: #(#E #Add #T).
	self assert: options isEmpty.
	newNode := (node evaluateUsing: grammar) valueWithPossibleArgs: (Array with: 0 with: Stack new).
	self assert: newNode numberOfNodes equals: 7.
	self deny: newNode nodeValue equals: node nodeValue.
	self assert: newNode ast formattedCode equals: '8 + (1 / 10)'
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
	tree := grammar expandTree: #E.
	self assert: tree id equals: #T.
	self assert: tree withAllChildren size equals: 1.
	self assert: tree nodeValue equals: 5
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingWeightsAndLongDepth [

	| tree configuration |
	grammar
		addSelectorRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addSelectorRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T ofClass: RBMessageNode withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F ofClass: RBLiteralNode
		withValues: ((1 to: 10) collect: [:n | GPDigit value: n]).
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
	tree := grammar expandGiven: configuration.
	self assert: tree id equals: #T.
	self assert: tree numberOfNodes equals: 10.
	self assert: tree ast evaluate value equals: 315
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfLiteral [

	| tree |
	grammar
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: #( 1 5 6 2 3 9 ).
	tree := grammar expand.
	self assert: tree numberOfNodes equals: 1.
	self assert: tree ast equals: (RBParser parseExpression: '3')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfRoassal3 [

	| tree configuration |
	grammar
		seed: 100;
		addRule: #Statements withCollectionOptions: #( #Assignment #Message ) ofSize: 1;
		addRule: #Assignment ofClass: RBAssignmentNode withSequence: #( #Variable #Value );
		addRule: #Message ofClass: RBMessageNode withSequence: #( #Value #Selector );
		addSelectorRule: #Selector withValues: #( #size );
		addRule: #Value withOptions: #( #Message #Variable );
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #( #shapes ).
	configuration := GPConfiguration new
		                 forRule: #Value putWeights: #( 10 2 );
		                 depth: 5.
	tree := grammar expandTree: #Statements given: configuration.
	self
		assert: tree ast formattedCode
		equals: 'shapes size size'
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGeneratingManyTrees [

	| config asts |
	config := GPConfiguration new.
	config forRule: #E putWeights: #( 100 10 10 ).
	asts := (1 to: 3) collect: [ :i | 
		        | tree |
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

		        tree := grammar expandTree: #E given: config.
		        tree ast formattedCode ].
	self assert: asts asSet size > 1
]

{ #category : #tests }
GPContextFreeGrammarTest >> testSimpleExample [

	| tree |
	grammar
		seed: 342423;
		addRule: #E
		ofClass: RBMessageNode
		withSequence: #( #E #AddOp #E ).
	grammar addRule: #E redirectingTo: #Number.
	grammar addSelectorRule: #AddOp withValues: #( #+ ).
	grammar
		addLeafRule: #Number
		ofClass: RBLiteralNode
		withValues: (-30 to: 30).
	tree := grammar expandTree: #E withDepth: 10.
	self assert: tree numberOfNodes equals: 49.
	self assert: tree ast evaluate equals: 83
]

{ #category : #tests }
GPContextFreeGrammarTest >> testSimpleExample2 [

	| tree configuration |
	grammar
		seed: 689669;
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
	tree := grammar expandTree: #E given: configuration.
	self assert: tree numberOfNodes equals: 16.
	self assert: tree ast evaluate equals: 25
	"self assert: ast evaluate equals: 20"
]
