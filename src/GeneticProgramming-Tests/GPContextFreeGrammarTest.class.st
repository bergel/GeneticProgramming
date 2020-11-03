Class {
	#name : #GPContextFreeGrammarTest,
	#superclass : #TestCase,
	#instVars : [
		'grammar',
		'random'
	],
	#category : #'GeneticProgramming-Tests'
}

{ #category : #running }
GPContextFreeGrammarTest >> setUp [

	 super setUp.
	 grammar := GPContextFreeGrammar new.
	random := GPRandom instance seed: 10
]

{ #category : #running }
GPContextFreeGrammarTest >> tearDown [

	 
	 GPRandom resetInstance.
	super tearDown.
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddLeafRuleWithValues [

	| result |
	random seed: 1.
	grammar addLeafRule: #F withValues: (1 to: 15) asArray. "((1 to: 10) collect: [ :n | GPDigit value: n ])."
	result := grammar expand.
	self assert: result id equals: #F.
	self assert: result numberOfNodes equals: 1.
	self assert: (result evaluate: grammar) equals: 2
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleOfClassWithSequence [

	| result |
	random seed: 1.
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
	result := grammar expandFrom: #Assignment.
	self assert: result numberOfNodes equals: 3
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleWithCollectionOptions [

	| result |
	random seed: 1.
	grammar
		addLeafRule: #number
		ofClass: RBLiteralNode
		withValues: #( 1 2 3 4 5 6 );
		addRule: #numbers withCollectionOptions: #( #number ).
	result := grammar expandFrom: #numbers.
	self assert: result numberOfNodes equals: 1.
	self assert: result value isEmpty
	"result := grammar expandFrom: #numbers ofSize: 4.
	self
		assertCollection: (result evaluate: grammar)
		hasSameElements: #( 1 5 3 4 )"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpand [

	| result |
	random seed: 1.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	result := grammar expand.
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 13.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
		#( #E #T #F #MulOp #F #AddOp #T #T #F #MulOp #F #MulOp #F ).
	self assert: (result evaluate: grammar) value equals: 13 / 28
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandFrom [

	 | result |
	 random seed: 1.
	 grammar
		 addMessageRule: #AddOp withValues: #( #sum: #sub: );
		 addRule: #E withSequence: #( #E #AddOp #T );
		 addRule: #E redirectingTo: #T;
		 addMessageRule: #MulOp withValues: #( #mul: #div: );
		 addRule: #T withSequence: #( #T #MulOp #F );
		 addRule: #T redirectingTo: #F;
		 addLeafRule: #F
		 withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	 result := grammar expandFrom: #T.
	 "result -> 			T
					  T  MulOp	F
				 F MulOp F "
	 self assert: result id equals: #T.
	 self assert: result numberOfNodes equals: 7.
	 self
		 assertCollection: (result withAllChildren collect: #id)
		 hasSameElements: #( #T #T #T #F #MulOp #F #MulOp #F ).
	 self assert: (result evaluate: grammar) value equals: 35 / 3
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandFromWithLogicExample [

	| result |
	random seed: 1.
	grammar
		addMessageRule: #LogOp withValues: #( #and: #or: );
		addRule: #E withSequence: #( #E #LogOp #T );
		addRule: #E redirectingTo: #T;
		addLeafRule: #T
		withValues:
			(Array with: (GPBool value: true) with: (GPBool value: false)).
	result := grammar expandFrom: #E.
	"result -> 			E
					 E   and:   T
				 T and: T
				    "
	self assert: result numberOfNodes equals: 7.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #E #E #E #T #LogOp #T #LogOp #T ).
	self assert: (result evaluate: grammar) logicValue equals: false
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodes [

	| result |
	"Assign -> Variable Value
	Variable -> #a | #v | #m
	Value -> Literal | Message
	Message -> Receiver Selector Args
	Literal -> 1 .. 10 
	Receiver -> Literal 
	Selector -> #+ | #- 
	Args -> #(Literal)"
	random seed: 78652.
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
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ).
	result := grammar expandFrom: #Assignment.
	"result -> 			 		Ass
						  	Var  			Mess
							 a		  Lit Sel  Args
									  2  +    Lit
									           1          
				           "
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 6.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
		#( #Assignment #Variable #Message #Literal #Selector #Args ).
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
		addRule: #Receiver redirectingTo: #Literal;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ).
	result := grammar expandFrom: #Assignment.
	"result -> 			 		Ass
						  	Var  			 Mess
									   Lit  Sel  Args
									    6    +    Mes
												  Lit Sel  Args	
												   2  -     Mes 
												        Ar  Sel  As
												                 Mes
												              Lt  Sel  As
																			 Lt
																       	  
				           "
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 6
	"result := result value.
	self assert: result evaluate equals: 10"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursively2 [

	| result |
	random seed: 78661.
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
	result := grammar expandFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 6
	"result := result value.
	self assert: result evaluate equals: 63"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursivelyWithColorExample [

	| result |
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
		withValues:
			(#( #blue #red #yellow #black #green #pink ) collect: [ :s | 
					 Color perform: s ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addMessageRule: #Selector withValues: #( #lighter #asColor );
		addRule: #Args withCollectionOptions: #( #Value ).
	result := grammar expandFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 15
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
	random seed: 1.
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
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 4 10 ) forRule: #Value;
		                 addOptionWeights: #( 7 6 ) forRule: #Selector;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #Literal.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Variable.
	self assert: result numberOfNodes equals: 1.
	"result := result value.
	self assert: result equals: (RBVariableNode named: #a)"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesWithWeights2 [

	| result configuration |
	random seed: 78652.
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
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 4 10 ) forRule: #Value;
		                 addOptionWeights: #( 7 6 ) forRule: #Selector;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #Literal.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Message.
	self assert: result numberOfNodes equals: 4
	"result := result value.
	self assert: result evaluate equals: 1"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnFooExample [

	| result configuration |
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
		                 depth: 20.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 3
	"result := grammar replaceValuesOf: result.
	self assert: result evaluate equals: -14"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnMethodNode [

	| result configuration |
	random seed: 1.
	grammar
		addRule: #Method
		ofClass: RBMethodNode
		withSequence: #( #Selector #Body #Arguments );
		addLeafRule: #Selector withValues: #( #add );
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
		addMessageRule: #Selector withValues: #( #foo: #bar: #+ #- #* );
		addRule: #Arguments withOptions: #( #Value );
		addRule: #Value
		withOptions: #( #Message #Variable #Literal #Block );
		addRule: #Block
		ofClass: RBBlockNode
		withSequence: #( #Arguments #Body );
		addRule: #Colons withCollectionOptions: #(  );
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

	| result configuration |
	random seed: 1.
	"grammar"
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
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: #(  ). "#Message" "#Block"
	"weights "
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 19 )
		                 forRule: #Method.
	"expand nodes of grammar"
	result := grammar expandFrom: #Method given: configuration.
	self assert: result id equals: #Method
	"self assert: result numberOfNodes equals: 12."
	"result := grammar replaceValuesOf: result.
	self assert: (RSCanvas new perform: result selector) equals: 0"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnMethodNodeOfRoassal3WithDepth [

	| result configuration |
	random seed: 100.
	"grammar"
	grammar
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
		addRule: #Temporaries withCollectionOptions: #( #Variable );
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: #( 1 ). "#Statements"
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 10 2 3 )
		                 forRule: #Value. "1" ";
		                 depth: 7"
	"addOptionWeights: #( 19 ) forRule: #Method;"
	"expand nodes of grammar"
	result := grammar expandFrom: #Statements given: configuration.
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
	random seed: 78652.
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
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Literal ).
	result := grammar expandFrom: #Assignment.
	"result -> 			 		Ass
						  	Var  			 Mess
							m		  Lit Sel  Args
									  6    +   Lit
										         1        
				           "
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 6.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
		#( #Assignment #Variable #Message #Literal #Selector #Args )
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
	random seed: 78652.
	grammar
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: (1 to: 10) asArray.
	result := grammar expandFrom: #Literal.
	"result -> 			 		Lit
										2    
				           "
	self assert: result id equals: #Literal.
	self assert: result numberOfNodes equals: 1.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #Literal ).
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsing [

	| result configuration |
	random seed: 1.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
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
	result := grammar expandUsing: configuration.
	"result -> 			F  "
	self assert: result id equals: #F.
	self assert: result numberOfNodes equals: 1.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #F ).
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 6
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingAnotherSeed [

	| result configuration |
	random seed: 78652.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
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
	result := grammar expandUsing: configuration.
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 64.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 581 / 6
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingAnotherSeed2 [

	| result configuration |
	random seed: 19683.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
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
	result := grammar expandUsing: configuration.
	self assert: result id equals: #F.
	"self assert: result numberOfNodes equals: 8.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #T #T #T #F #MulOp #F #MulOp #F ).
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 49"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingLongerSeed [

	| result configuration |
	random seed: 689667.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
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
	result := grammar expandUsing: configuration.
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 40.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 7144481
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingWeightsAndLongDepth [

	| result configuration |
	random seed: 1.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPASTConfiguration new
		                 addWeight: 8 forRule: #E;
		                 addWeight: 5 forRule: #T;
		                 addWeight: 4 forRule: #F;
		                 addOptionWeights: #( 8 5 ) forRule: #E;
		                 addOptionWeights: #( 6 3 ) forRule: #T;
		                 addOptionWeights: #( 6 4 ) forRule: #AddOp;
		                 addOptionWeights: #( 6 3 ) forRule: #MulOp;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #F;
		                 depth: 5.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #T.
	self assert: result numberOfNodes equals: 13.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 735 / 2
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingWithoutWeightsOfRules [

	| result configuration |
	random seed: 1.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 8 5 ) forRule: #E;
		                 addOptionWeights: #( 6 3 ) forRule: #T;
		                 addOptionWeights: #( 6 4 ) forRule: #AddOp;
		                 addOptionWeights: #( 6 3 ) forRule: #MulOp;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #F.
	result := grammar expandUsing: configuration.
	"result -> 			F  "
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 13.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 421/9
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandWithWeightsAndDepth [

	| result configuration |
	random seed: 68921.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPASTConfiguration new
		                 addWeight: 8 forRule: #E;
		                 addWeight: 5 forRule: #T;
		                 addWeight: 4 forRule: #F;
		                 addOptionWeights: #( 8 5 ) forRule: #E;
		                 addOptionWeights: #( 6 3 ) forRule: #T;
		                 addOptionWeights: #( 6 4 ) forRule: #AddOp;
		                 addOptionWeights: #( 6 3 ) forRule: #MulOp;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #F;
		                 depth: 1.
	result := grammar expandUsing: configuration.
	"result -> 		F  "
	self assert: result id equals: #F.
	self assert: result numberOfNodes equals: 1.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 5
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandWithWeightsAndLongerDepth [

	| result configuration |
	random seed: 1.
	grammar
		addMessageRule: #AddOp withValues: #( #sum: #sub: );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #mul: #div: );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F
		withValues: ((1 to: 10) collect: [ :n | GPDigit value: n ]).
	configuration := GPASTConfiguration new
		                 addWeight: 8 forRule: #E;
		                 addWeight: 5 forRule: #T;
		                 addWeight: 4 forRule: #F;
		                 addOptionWeights: #( 8 5 ) forRule: #E;
		                 addOptionWeights: #( 6 3 ) forRule: #T;
		                 addOptionWeights: #( 6 4 ) forRule: #AddOp;
		                 addOptionWeights: #( 6 3 ) forRule: #MulOp;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #F;
		                 depth: 10.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #T.
	self assert: result numberOfNodes equals: 28.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 18
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateAST [

	| result ast |
	random seed: 1.
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
	result := grammar expandFrom: #Assignment.
	self assert: result numberOfNodes equals: 3.
	ast := grammar generateASTFrom: result.
	self assert: ast equals: (RBParser parseExpression: 'a := 3')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfLiteral [

	| result ast |
	random seed: 1.
	grammar
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues: #( 1 5 6 2 3 9 ).
	result := grammar expand.
	self assert: result numberOfNodes equals: 1.
	ast := grammar generateASTFrom: result.
	self assert: ast equals: (RBParser parseExpression: '1')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfMessage [

	| result ast |
	random seed: 1.
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
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ).
	result := grammar expandFrom: #Message.
	self assert: result numberOfNodes equals: 4.
	ast := grammar generateASTFrom: result.
	self assert: ast equals: (RBParser parseExpression: '8 + (7 - v)')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfMessage2 [

	| result ast |
	random seed: 45226.
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
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ).
	result := grammar expandFrom: #Message.
	self assert: result numberOfNodes equals: 4.
	ast := grammar generateASTFrom: result.
	self assert: ast equals: (RBParser parseExpression: '1 - v')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfMessage3 [

	| result ast |
	random seed: 613216.
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
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withCollectionOptions: #( #Value ).
	result := grammar expandFrom: #Message.
	self assert: result numberOfNodes equals: 4.
	ast := grammar generateASTFrom: result.
	self
		assert: ast
		equals: (RBParser parseExpression: '3 - (8 + (3 + (7 - a)))')
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerateASTOfRoassal3 [

	| result configuration ast |
	random seed: 100.
	"grammar"
	grammar
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
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #shapes );
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: #( 1 ). "#Block"
	"addRule: #Block
		ofClass: RBBlockNode
		withSequence: #( #Arguments #Body );
		addRule: #Body redirectingTo: #Sequence;
		addRule: #Sequence
		ofClass: RBSequenceNode
		withSequence: #( #Temporaries );
		addRule: #Temporaries withCollectionOptions: #( #Variable )" "#Statements"
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 10 2 3 ) forRule: #Value;
		                 depth: 3.
	result := grammar expandFrom: #Statements given: configuration.
	ast := grammar generateASTFrom: result.
	self
		assert: ast
		equals: (Array with: (RBParser parseExpression: 'shapes size size'))
]
