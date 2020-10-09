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
GPContextFreeGrammarTest >> testGenerationTree1 [

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
		 hasSameElements: #( #E #E #T #T #F #MulOp #AddOp #T #T #T #F #MulOp #F #MulOp #F ).
	 self assert: (result evaluate: grammar) value equals: 13 / 28
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerationTree10 [

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
		                  depth: 2.
	 result := grammar expandUsing: configuration.
	 "result -> 														T
																		F"
	 self assert: result id equals: #T.
	 self assert: result numberOfNodes equals: 2.
	 self
		 assert: (result evaluate: grammar given: configuration) value
		 equals: 9
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerationTree11 [

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
GPContextFreeGrammarTest >> testGenerationTree12 [

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
		                  depth: 4.
	 result := grammar expandUsing: configuration.
	 "result -> 														T
																T    MulOp     F
															T MulOp  F
															F"
	 self assert: result id equals: #T.
	 self assert: result numberOfNodes equals: 8.
	 self
		 assert: (result evaluate: grammar given: configuration) value
		 equals: 54
]

{ #category : #tests }
GPContextFreeGrammarTest >> testGenerationTree2 [

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
GPContextFreeGrammarTest >> testGenerationTree3 [

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
GPContextFreeGrammarTest >> testGenerationTree4 [

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
GPContextFreeGrammarTest >> testGenerationTree5 [

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
GPContextFreeGrammarTest >> testGenerationTree6 [

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
GPContextFreeGrammarTest >> testGenerationTree7 [

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
GPContextFreeGrammarTest >> testGenerationTree8 [

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
GPContextFreeGrammarTest >> testGenerationTree9 [

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
