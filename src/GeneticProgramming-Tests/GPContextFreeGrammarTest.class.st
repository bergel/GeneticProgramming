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
		addLeafRule: #Variable withValues: (Array
				 with: (RBVariableNode named: #a)
				 with: (RBVariableNode named: #v)
				 with: (RBVariableNode named: #m));
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		withValues:
			((1 to: 10) collect: [ :n | RBLiteralValueNode value: n ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withSequence: #( #Literal ).
	result := grammar expandFrom: #Assignment.
	"result -> 			 		Ass
						  	Var  			Val
						    a          Mess
									  Rcv Sel  Args
									  Lit  +    Lit
										2         1
				           "
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 9.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
			#( #Assignment #Variable #Value #Message #Receiver #Literal
			   #Selector #Args #Literal ).
	result := grammar replaceValuesOf: result.
	self assert: result equals: (RBAssignmentNode
			 variable: (RBVariableNode named: #v)
			 value: (RBMessageNode
					  receiver: (RBLiteralNode value: 2)
					  selector: #+
					  arguments: (Array with: (RBLiteralNode value: 1)))).
	self assert: result evaluate equals: 3
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursively [

	| result |
	random seed: 78652.
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
		withValues:
			((1 to: 10) collect: [ :n | RBLiteralValueNode value: n ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withSequence: #( #Value ).
	result := grammar expandFrom: #Assignment.
	"result -> 			 		Ass
						  	Var  				Val
						    a          	   Mess
									      Rcv Sel  Args
									      Lit  +    Val
								     		 2		    Mes
													Rcv Sel Ar	
													Lit  -  Val
													 2		  Lit
																10
				           "
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 16.
	result := grammar replaceValuesOf: result.
	self assert: result evaluate equals: -6
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursively2 [

	| result |
	random seed: 78659.
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
		withValues:
			((1 to: 10) collect: [ :n | RBLiteralValueNode value: n ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withSequence: #( #Value ).
	result := grammar expandFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 102.
	result := grammar replaceValuesOf: result.
	self assert: result evaluate equals: 5
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursivelyWithColorExample [

	| result |
	random seed: 78659.
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
		withValues:
			(#( #blue #red #yellow #black #green #pink ) collect: [ :c | 
					 RBLiteralValueNode value: (Color perform: c) ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addMessageRule: #Selector withValues: #( #lighter #asColor );
		addRule: #Args withSequence: #( #Value ).
	result := grammar expandFrom: #Assignment.
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 102.
	result := grammar replaceValuesOf: result.
	self assert: result evaluate equals: Color pink lighter lighter
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesRecursivelyWithWeigthsAndDepth [

	| result configuration |
	random seed: 78653.
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
		withValues:
			((1 to: 10) collect: [ :n | RBLiteralValueNode value: n ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Value;
		addMessageRule: #Selector withValues: #( #+ #- );
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
GPContextFreeGrammarTest >> testExpandOnASTNodesWithTwoOptions [

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
		addLeafRule: #Variable withValues: (Array
				 with: (RBVariableNode named: #a)
				 with: (RBVariableNode named: #v)
				 with: (RBVariableNode named: #m));
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		withValues:
			((1 to: 10) collect: [ :n | RBLiteralValueNode value: n ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withSequence: #( #Literal ).
	result := grammar expandFrom: #Assignment.
	"result -> 			 		Ass
						  	Var  			Val
						    a          Mess
									  Rcv Sel  Args
									  Lit  +    Lit
										2         1
				           "
	self assert: result id equals: #Assignment.
	self assert: result numberOfNodes equals: 9.
	self
		assertCollection: (result withAllChildren collect: #id)
		hasSameElements:
			#( #Assignment #Variable #Value #Message #Receiver #Literal
			   #Selector #Args #Literal ).
	result := grammar replaceValuesOf: result.
	self assert: result equals: (RBAssignmentNode
			 variable: (RBVariableNode named: #v)
			 value: (RBMessageNode
					  receiver: (RBLiteralNode value: 2)
					  selector: #+
					  arguments: (Array with: (RBLiteralNode value: 1)))).
	self assert: result evaluate equals: 3
]

{ #category : #tests }
GPContextFreeGrammarTest >> testExpandOnASTNodesWithWeights [

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
		withValues:
			((1 to: 10) collect: [ :n | RBLiteralValueNode value: n ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withSequence: #( #Literal ).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 4 10 ) forRule: #Value;
		                 addOptionWeights: #( 7 6 ) forRule: #Selector;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #Literal.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Variable.
	self assert: result numberOfNodes equals: 1.
	result := grammar replaceValuesOf: result.
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
		addLeafRule: #Variable withValues: (Array
				 with: (RBVariableNode named: #a)
				 with: (RBVariableNode named: #v)
				 with: (RBVariableNode named: #m));
		addRule: #Value withOptions: #( #Literal #Message );
		addLeafRule: #Literal
		withValues:
			((1 to: 10) collect: [ :n | RBLiteralValueNode value: n ]);
		addRule: #Message
		ofClass: RBMessageNode
		withSequence: #( #Receiver #Selector #Args );
		addRule: #Receiver redirectingTo: #Literal;
		addMessageRule: #Selector withValues: #( #+ #- );
		addRule: #Args withSequence: #( #Literal ).
	configuration := GPASTConfiguration new
		                 addOptionWeights: #( 4 10 ) forRule: #Value;
		                 addOptionWeights: #( 7 6 ) forRule: #Selector;
		                 addOptionWeights: #( 4 6 3 8 9 7 7 2 6 5 )
		                 forRule: #Literal.
	result := grammar expandUsing: configuration.
	self assert: result id equals: #Message.
	self assert: result numberOfNodes equals: 6.
	result := grammar replaceValuesOf: result.
	self assert: result evaluate equals: 1
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

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerationTree13 [

	| result str |
	random seed: 1.
	grammar
		addMessageRule: #AddOp withValues: #( #+ #- );
		addRule: #E withSequence: #( #E #AddOp #T );
		addRule: #E redirectingTo: #T;
		addMessageRule: #MulOp withValues: #( #* #/ );
		addRule: #T withSequence: #( #T #MulOp #F );
		addRule: #T redirectingTo: #F;
		addLeafRule: #F withValues: (1 to: 10) asArray.
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
	str := (result withAllChildren collect: [ :s | s asString , ' ' ])
		       trimBoth.
	self assert: str equals: '3 * 5 + 4 * 4 * 7'.
	self assert: (Smalltalk compiler evaluate: str) equals: 13 / 28
	"self
		assertCollection: (result withAllChildren collect: #print)
		hasSameElements: #( '3' '*' '5' '+' '4' '*' '4' '*' '7' ).
	self assert: (result evaluate: grammar) value equals: 13 / 28"
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerationTree14 [

	 | result |
	 random seed: 1.
	 "E -> E Msg
	  E -> F
	  F -> Color
	  Msg -> asColor | colorForInsets | lighter"
	 grammar
		 addMessageRule: #Msg
		 withValues: #( #asColor #colorForInsets #lighter );
		 addRule: #E withSequence: #( #E #Msg );
		 addRule: #E redirectingTo: #F;
		 addLeafRule: #F withValues: (Array
				  with: Color blue
				  with: Color black
				  with: Color red
				  with: Color green
				  with: Color yellow).
	 result := grammar expand.
	 "result -> 			 E
						  E  Msg
				        F   "
	 self assert: result id equals: #E.
	 self assert: result numberOfNodes equals: 4.
	 self
		 assertCollection: (result withAllChildren collect: #id)
		 hasSameElements: #( #E #E #F #Msg ).
	self assertCollection: (result withAllChildren collect: #print) hasSameElements: #('Color red asColor').
	 self assert: (result evaluate: grammar) equals: Color red
]
