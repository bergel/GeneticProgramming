Class {
	#name : #GPAssertConfigurationTest,
	#superclass : #TestCase,
	#instVars : [
		'dictFunction',
		'dictObjective',
		'configuration'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #initialization }
GPAssertConfigurationTest >> setUp [ 
	configuration := GPAssertConfiguration new.
	GPRandom seed: 1345
]

{ #category : #tests }
GPAssertConfigurationTest >> testCountErrorsGiven [
	"configuration options: #(1 2 -2 4 $e $r $, 'asdf' nil #(Greeting Integer));
		targetSelector: #columns:;
		targetClass: DataFrame;
		testClass: DataFrameTest.
	self assert: (configuration countErrorsGiven: [ DataFrame new ]) equals: 30.
	self assert: (configuration countErrorsGiven: [ 
		(DataFrame withRows: #((Hi 0) (World 1)))
		rowNames: #(A B);
		columnNames: #(Greeting Integer) ]) equals: 23"
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWith [
	| ind1 ind2 |
	ind1 := GPNode new 
		id: #Assertion;
		depth: 0;
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ];
		type: RBMessageNode;
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #Self; nodeValue: 'self'; type: RBVariableNode; depth: 1;
				printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: 'Assert'; nodeValue: 'assert:'; depth: 1; 
				printBlock: [:n :ctx | n nodeValue ]);
			add: (GPNode new 
				id: #Method;
				type: RBMessageNode;
				depth: 1;
				printBlock: [:n :ctx | [ (n withAllChildren collect: #id) asArray asString]];
				children: (OrderedCollection new
					add: (GPLeafNode new id: #Variable; depth: 2; nodeValue: 'arrayOfNames'; type: RBVariableNode;
						printBlock: [:n :ctx | n nodeValue asString ]);
					add: (GPSelectorNode new id: #Message; nodeValue: #notEmpty; depth: 2; 
						printBlock: [:n :ctx | n nodeValue ]);
					yourself) );
			yourself).
	ind2 := GPNode new 
		id: #Assertion;
		depth: 0;
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ];
		type: RBMessageNode;
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #Self; nodeValue: 'self'; type: RBVariableNode; depth: 1;
				printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: 'Assert'; nodeValue: 'assert:'; depth: 1; 
				printBlock: [:n :ctx | n nodeValue ]);
			add: (GPNode new 
				id: #Method;
				type: RBMessageNode;
				depth: 1;
				printBlock: [:n :ctx | [ (n withAllChildren collect: #id) asArray asString]];
				children: (OrderedCollection new
					add: (GPLeafNode new id: #Variable; depth: 2; nodeValue: 'arrayOfLastNames'; type: RBVariableNode;
						printBlock: [:n :ctx | n nodeValue asString ]);
					add: (GPSelectorNode new id: #Message; nodeValue: #empty; depth: 2; 
						printBlock: [:n :ctx | n nodeValue ]);
					yourself) );
			yourself).
	self assert: ind1 print equals: 'self assert: arrayOfNames notEmpty'.
	self assert: ind2 print equals: 'self assert: arrayOfLastNames empty'.
	self assert: (configuration crossover: ind1 with: ind2) print equals: 'self assert: arrayOfNames empty'
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWith1 [
	| individual1 individual2 offspring |
	GPRandom seed: 8.
	individual1 := GPNode new 
		id: #Assertion;
		depth: 0;
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ];
		type: RBMessageNode;
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #Self; nodeValue: 'self'; type: RBVariableNode; depth: 1;
				printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: 'Assert'; nodeValue: 'assert:'; depth: 1; 
				printBlock: [:n :ctx | n nodeValue ]);
			add: (GPNode new 
				id: #Method;
				type: RBMessageNode;
				depth: 1;
				printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString];
				children: (OrderedCollection new
					add: (GPNode new id: #Method; depth: 2; 
						type: RBMessageNode;
						printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString ];
						children: (OrderedCollection new 
							add: (GPLeafNode new id: #Variable; depth: 3; nodeValue: 'arrayOfNames'; type: RBVariableNode;
								printBlock: [:n :ctx | n nodeValue asString ]);
							add: (GPSelectorNode new id: #Message; nodeValue: #notEmpty; depth: 3; 
								printBlock: [:n :ctx | n nodeValue ]);
							yourself);
						nodeValue: #('arrayOfNames' #notEmpty) asOrderedCollection);
					add: (GPSelectorNode new id: #And; depth: 2; nodeValue: #and:; 
						printBlock: [:n :ctx | n nodeValue ]);
					add: (GPNode new id: #Block; depth: 2;  type: RBBlockNode;
						printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString ];
						children: (OrderedCollection new 
							add: (GPNode new id: #Method; depth: 3; 
								type: RBMessageNode;
								printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString ];
								children: (OrderedCollection new 
									add: (GPLeafNode new id: #Variable; depth: 4; nodeValue: 'arrayOfNames'; type: RBVariableNode;
										printBlock: [:n :ctx | n nodeValue asString ]);
									add: (GPSelectorNode new id: #Satisfy; nodeValue: #allSatisfy:; depth: 4; 
										printBlock: [:n :ctx | n nodeValue ]);
									add: (GPLeafNode new id: #Message; nodeValue: #isString; depth: 4;  type: RBLiteralNode;
										printBlock: [:n :ctx | n nodeValue asString ]);
									yourself));
							yourself);
						nodeValue: #('arrayOfNames' #allSatisfy: #isString) asOrderedCollection);
					yourself));
			yourself).
	individual2 := GPNode new 
		id: #Assertion;
		depth: 0;
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ];
		type: RBMessageNode;
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #Self; nodeValue: 'self'; type: RBVariableNode; depth: 1;
				printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: 'Assert'; nodeValue: 'assert:'; depth: 1; 
				printBlock: [:n :ctx | n nodeValue ]);
			add: (GPNode new 
				id: #Method;
				type: RBMessageNode;
				depth: 1;
				printBlock: [:n :ctx | [ (n withAllChildren collect: #id) asArray asString]];
				children: (OrderedCollection new
					add: (GPLeafNode new id: #Variable; depth: 2; nodeValue: 'arrayOfNames'; type: RBVariableNode;
						printBlock: [:n :ctx | n nodeValue asString ]);
					add: (GPSelectorNode new id: #Message; nodeValue: #empty; depth: 2; 
						printBlock: [:n :ctx | n nodeValue ]);
					yourself) );
			yourself).
	self assert: individual1 print equals: (RBParser parseExpression: 'self assert: (arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ])') formattedCode.
	self assert: individual2 print equals: 'self assert: arrayOfNames empty'.
	offspring := configuration crossover: individual1 with: individual2.
	self assert: offspring print equals: (RBParser parseExpression: 'self assert: (arrayOfNames empty and: [ arrayOfNames allSatisfy: #isString ])') formattedCode
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateWith [
	| individual1 individual2 |
	individual1 := GPNode new 
		id: #Assertion;
		depth: 0;
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ];
		type: RBMessageNode;
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #Self; nodeValue: 'self'; type: RBVariableNode; depth: 1;
				printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: 'Assert'; nodeValue: 'assert:'; depth: 1; 
				printBlock: [:n :ctx | n nodeValue ]);
			add: (GPNode new 
				id: #Method;
				type: RBMessageNode;
				depth: 1;
				printBlock: [:n :ctx | [ (n withAllChildren collect: #id) asArray asString]];
				children: (OrderedCollection new
					add: (GPLeafNode new id: #Variable; depth: 2; nodeValue: 'arrayOfNames'; type: RBVariableNode;
						printBlock: [:n :ctx | n nodeValue asString ]);
					add: (GPSelectorNode new id: #Message; nodeValue: #notEmpty; depth: 2; 
						printBlock: [:n :ctx | n nodeValue ]);
					yourself) );
			yourself).
	individual2 := GPNode new 
		id: #Assertion;
		depth: 0;
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ];
		type: RBMessageNode;
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #Self; nodeValue: 'self'; type: RBVariableNode; depth: 1;
				printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: 'Assert'; nodeValue: 'assert:'; depth: 1; 
				printBlock: [:n :ctx | n nodeValue ]);
			add: (GPNode new 
				id: #Method;
				type: RBMessageNode;
				depth: 1;
				printBlock: [:n :ctx | [ (n withAllChildren collect: #id) asArray asString]];
				children: (OrderedCollection new
					add: (GPLeafNode new id: #Variable; depth: 2; nodeValue: 'arrayOfNames'; type: RBVariableNode;
						printBlock: [:n :ctx | n nodeValue asString ]);
					add: (GPSelectorNode new id: #Message; nodeValue: #empty; depth: 2; 
						printBlock: [:n :ctx | n nodeValue ]);
					yourself) );
			yourself).
	self assert: individual1 print equals: 'self assert: arrayOfNames notEmpty'.
	self assert: individual2 print equals: 'self assert: arrayOfNames empty'.
	configuration mutate: individual1 with: individual2.
	self assert: individual1 print equals: 'self assert: arrayOfNames empty'
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateWith1 [
	| individual1 individual2 |
	GPRandom seed: 8.
	individual1 := GPNode new 
		id: #Assertion;
		depth: 0;
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ];
		type: RBMessageNode;
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #Self; nodeValue: 'self'; type: RBVariableNode; depth: 1;
				printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: 'Assert'; nodeValue: 'assert:'; depth: 1; 
				printBlock: [:n :ctx | n nodeValue ]);
			add: (GPNode new 
				id: #Method;
				type: RBMessageNode;
				depth: 1;
				printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString];
				children: (OrderedCollection new
					add: (GPNode new id: #Method; depth: 2; 
						type: RBMessageNode;
						printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString ];
						children: (OrderedCollection new 
							add: (GPLeafNode new id: #Variable; depth: 3; nodeValue: 'arrayOfNames'; type: RBVariableNode;
								printBlock: [:n :ctx | n nodeValue asString ]);
							add: (GPSelectorNode new id: #Message; nodeValue: #notEmpty; depth: 3; 
								printBlock: [:n :ctx | n nodeValue ]);
							yourself);
						nodeValue: #('arrayOfNames' #notEmpty) asOrderedCollection);
					add: (GPSelectorNode new id: #And; depth: 2; nodeValue: #and:; 
						printBlock: [:n :ctx | n nodeValue ]);
					add: (GPNode new id: #Block; depth: 2;  type: RBBlockNode;
						printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString ];
						children: (OrderedCollection new 
							add: (GPNode new id: #Method; depth: 3; 
								type: RBMessageNode;
								printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString ];
								children: (OrderedCollection new 
									add: (GPLeafNode new id: #Variable; depth: 4; nodeValue: 'arrayOfNames'; type: RBVariableNode;
										printBlock: [:n :ctx | n nodeValue asString ]);
									add: (GPSelectorNode new id: #Satisfy; nodeValue: #allSatisfy:; depth: 4; 
										printBlock: [:n :ctx | n nodeValue ]);
									add: (GPLeafNode new id: #Message; nodeValue: #isString; depth: 4;  type: RBLiteralNode;
										printBlock: [:n :ctx | n nodeValue asString ]);
									yourself));
							yourself);
						nodeValue: #('arrayOfNames' #allSatisfy: #isString) asOrderedCollection);
					yourself));
			yourself).
	individual2 := GPNode new 
		id: #Assertion;
		depth: 0;
		evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ];
		type: RBMessageNode;
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #Self; nodeValue: 'self'; type: RBVariableNode; depth: 1;
				printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: 'Assert'; nodeValue: 'assert:'; depth: 1; 
				printBlock: [:n :ctx | n nodeValue ]);
			add: (GPNode new 
				id: #Method;
				type: RBMessageNode;
				depth: 1;
				printBlock: [:n :ctx | [ (n withAllChildren collect: #id) asArray asString]];
				children: (OrderedCollection new
					add: (GPLeafNode new id: #Variable; depth: 2; nodeValue: 'arrayOfNames'; type: RBVariableNode;
						printBlock: [:n :ctx | n nodeValue asString ]);
					add: (GPSelectorNode new id: #Message; nodeValue: #empty; depth: 2; 
						printBlock: [:n :ctx | n nodeValue ]);
					yourself) );
			yourself).
	self assert: individual1 print equals: (RBParser parseExpression: 'self assert: (arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ])') formattedCode.
	self assert: individual2 print equals: 'self assert: arrayOfNames empty'.
	configuration mutate: individual1 with: individual2.
	self assert: individual1 print equals: (RBParser parseExpression: 'self assert: (arrayOfNames empty and: [ arrayOfNames allSatisfy: #isString ])') formattedCode
]
