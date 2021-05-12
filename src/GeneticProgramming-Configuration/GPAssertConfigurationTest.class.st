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
