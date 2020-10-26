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
	result := grammar expandReplacingFrom: #Assignment.
	self assert: result numberOfNodes equals: 3
]

{ #category : #tests }
GPContextFreeGrammarTest >> testAddRuleWithCollectionOptions [

	| result |
	random seed: 1.
	grammar
		addLeafRule: #number ofClass: RBLiteralNode withValues: #( 1 2 3 4 5 6 );
		addRule: #numbers withCollectionOptions: #( #number ).
	result := grammar expandReplacingFrom: #numbers.
	self assert: result numberOfNodes equals: 1.
	self assert: result value isEmpty.
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
	"result -> 			 E
					  E  AddOp	 T
				     T         T M F
				  T MulOp F  T M F  
				  F          F "
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 16.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
		#( #E #E #T #T #F #MulOp #AddOp #T #T #T #F #MulOp #F #MulOp #F ).
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
				 T MulOp F
				 F  "
	 self assert: result id equals: #T.
	 self assert: result numberOfNodes equals: 8.
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
				 E and: T
				 T   "
	self assert: result numberOfNodes equals: 8.
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
	result := grammar expandReplacingFrom: #Assignment.
	"result -> 			 		Ass
						  	Var  			Mess
							 a		  Lit Sel  Args
									  2  +    Lit
									           1          
				           "
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 7.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
		#( #Assignment #Variable #Message #Literal #Selector #Args #Literal ).
	result := result value.
	self assert: result equals: (RBAssignmentNode
			 variable: (RBVariableNode named: #m)
			 value: (RBMessageNode
					  receiver: (RBLiteralNode value: 6)
					  selector: #+
					  arguments: (Array with: (RBLiteralNode value: 1)))).
	self assert: result evaluate equals: 7
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
	result := grammar expandReplacingFrom: #Assignment.
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
	self assert: result numberOfNodes equals: 19.
	result := result value.
	self assert: result evaluate equals: 10
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursively2 [

	| result |
	random seed: 78665.
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
	result := grammar expandReplacingFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 4139.
	result := result value.
	self assert: result evaluate equals: 63
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
	result := grammar expandReplacingFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 18.
	result := result value.
	self
		assert: result evaluate
		equals: Color green lighter 
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursivelyWithWeigthsAndDepth [

	| result configuration |
	random seed: 78653.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #(#a #v #m);
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues:
			((1 to: 10) asArray);
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
	result := grammar expandReplacingUsing: configuration.
	self assert: result id equals: #Value.
	self assert: result numberOfNodes equals: 93.
	result := result value.
	self assert: result evaluate equals: -14
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursivelyWithWeigthsAndDepth2 [

	| result configuration |
	random seed: 78653.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable ofClass: RBVariableNode withValues: #(#a #v #m);
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues:
			((1 to: 10) asArray);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Arguments );
		addRule: #Receiver redirectingTo: #Value;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Arguments withCollectionOptions: #( #Value ).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 3 10 ) forRule: #Value;
		                 addOptionWeights: #( 7 2 ) forRule: #Selector;
		                 addOptionWeights: #( 7 6 2 8 1 3 6 4 8 1 )
		                 forRule: #Literal;
		                 depth: 20.
	result := grammar expandReplacingUsing: configuration.
	self assert: result id equals: #Value.
	self assert: result numberOfNodes equals: 93.
	result := result value.
	self assert: result evaluate equals: -14
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
	result := grammar expandReplacingUsing: configuration.
	self assert: result id equals: #Variable.
	self assert: result numberOfNodes equals: 1.
	result := result value.
	self assert: result equals: (RBVariableNode named: #a)
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesWithWeights2 [

	| result configuration |
	random seed: 78652.
	grammar
		addRule: #Assignment
		ofClass: RBAssignmentNode
		withSequence: #( #Variable #Value );
		addLeafRule: #Variable withValues: #(#a #v #m);
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		ofClass: RBLiteralNode
		withValues:
			((1 to: 10) asArray);
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
	result := grammar expandReplacingUsing: configuration.
	self assert: result id equals: #Message.
	self assert: result numberOfNodes equals: 6.
	result := result value.
	self assert: result evaluate equals: 1
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
		addRule: #Args withSequence: #( #Value ).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 3 10 ) forRule: #Value;
		                 addOptionWeights: #( 7 2 ) forRule: #Selector;
		                 addOptionWeights: #( 7 6 2 8 1 3 6 4 8 1 )
		                 forRule: #Literal;
		                 depth: 20.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Value.
	self assert: result numberOfNodes equals: 93.
	result := grammar replaceValuesOf: result.
	self assert: result evaluate equals: -14
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
	result := grammar expandReplacingFrom: #Method given: configuration.
	self assert: result id equals: #Method.
	"self assert: result numberOfNodes equals: 12."
	result := grammar replaceValuesOf: result.
	self assert: (RSCanvas new perform: result selector) equals: 0
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
		addRule: #Value withOptions: #( #Message #Variable #Literal );
		"addRule: #Block
		ofClass: RBBlockNode
		withSequence: #( #Arguments #Body );"
		addLeafRule: #Variable
		ofClass: RBVariableNode
		withValues: #( #shapes );
		addLeafRule: #Literal ofClass: RBLiteralNode withValues: #( 1 ). "#Block"
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 10 2 3 "1" )
		                 forRule: #Value. ";
		                 depth: 7"
	"addOptionWeights: #( 19 ) forRule: #Method;"
	"expand nodes of grammar"
	result := grammar
		          expandReplacingFrom: #Statements
		          given: configuration.
	self halt.
	"self assert: result id equals: #Method."
	"self assert: result numberOfNodes equals: 12."
	result := result value.
	self assert: (RSCanvas new perform: result selector) equals: 0
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
	result := grammar expandReplacingFrom: #Assignment. self halt.
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
		#( #Assignment #Variable #Message #Literal #Selector #Args #Literal ).
	result := result value.
	"
	result := grammar replaceValuesOf: result"
	self assert: result equals: (RBAssignmentNode
			 variable: (RBVariableNode named: #m)
			 value: (RBMessageNode
					  receiver: (RBLiteralNode value: 6)
					  selector: #+
					  arguments: (Array with: (RBLiteralNode value: 1)))).
	self assert: result evaluate equals: 7
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandReplacingFromLiteralNode [

	| result |
	random seed: 78652.
	grammar addLeafRule: #Literal ofClass: RBLiteralNode withValues: (1 to: 10) asArray.
	result := grammar expandReplacingFrom: #Literal.
	"result -> 			 		Lit
										2    
				           "
	self assert: result id equals: #Literal.
	self assert: result numberOfNodes equals: 1.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #Literal ).
	result := result value.
	self assert: result equals: (RBLiteralNode value: 7).
	self assert: result evaluate equals: 7
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
	"result -> 					E
						   E    AddOp   T
					 E  AddOp  T       F
				    T         F
			   T MulOp F
		    T Mo F 
	     T Mo F 
      T M F
    T M F
  T M F
  F"
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 29.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
			#( #E #E #E #T #T #T #T #T #T #T #F #MulOp #F #MulOp #F #MulOp
			   #F #MulOp #F #MulOp #F #MulOp #F #AddOp #T #F #AddOp #T #F ).
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 114 / 25
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
	"result -> 						T
								   T	MO	F
					 			T  MO  F
					   		   F"
	self assert: result id equals: #T.
	self assert: result numberOfNodes equals: 8.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements: #( #T #T #T #F #MulOp #F #MulOp #F ).
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 49
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandUsingLongerSeed [

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
		                 forRule: #F.
	result := grammar expandUsing: configuration.
	"result -> 														E
														E		  AOp			    T
												E	  AO   T					 T  MO  F
										E    AO    T		T M F			  T M F
							   E     AO    T	T M F	F				T M F
								T			T MO F F					 T M F
						T     MO    F	F							 F
				 T	   MO   F
			T  MO  F
		T  MO  F
	T  MO  F
	F"
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 55.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 9743 / 45
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
	"result -> 														E
																		T
																T    MulOp     F
															T MulOp  F
														   F"
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 9.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 24 / 5
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
	self assert: result numberOfNodes equals: 61.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 461/20
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
	"result -> 														E									
																		T
																T    MulOp     F
															T MulOp  F
														T Mu F
													T Mu F
												T Mu F
											T Mu F
										T Mu F
									   F"
	self assert: result id equals: #E.
	self assert: result numberOfNodes equals: 24.
	self
		assert: (result evaluate: grammar given: configuration) value
		equals: 150000
]
