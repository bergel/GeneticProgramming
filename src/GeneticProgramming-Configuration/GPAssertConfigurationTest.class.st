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

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node1 [ 
	"self asseer: arrayOfNames notEmpty"
	^  GPNode new 
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
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node2 [
	"self assert: arrayOfLastNames empty"
	^ GPNode new 
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
					add: (GPSelectorNode new id: #Message; nodeValue: #isEmpty; depth: 2; 
						printBlock: [:n :ctx | n nodeValue ]);
					yourself) );
			yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node3 [
	"self assert: (arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ])"
	^ GPNode new 
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
			yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node4 [
	"self assert: arrayOfNames empty"
	^ GPNode new 
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
					add: (GPSelectorNode new id: #Message; nodeValue: #isEmpty; depth: 2; 
						printBlock: [:n :ctx | n nodeValue ]);
					yourself) );
			yourself)
]

{ #category : #initialization }
GPAssertConfigurationTest >> setUp [
	GPRandom seed: 1345.
	configuration := GPAssertConfiguration new
]

{ #category : #tests }
GPAssertConfigurationTest >> testCountErrorsGiven [
	GPRandom seed: 3.
	configuration options: (OrderedCollection new 
		addAll: #(1 2 -2 4 $e $r $, 'asdf' nil #(Greeting Integer));
		"add: [ :obj | obj isArray and: [ obj allSatisfy: #isString ] ];"
		yourself);
	"configuration options: #(1 2 -2 4 $e $r $, 'asdf' nil #(Greeting Integer));"
		targetSelector: #sum:;
		targetClass: GPDigit.
	self assert: (configuration countErrorsGiven: [ GPDigit new ]) equals: 30.
	self assert: (configuration countErrorsGiven: [ GPDigit new value: 4 ]) equals: 18.
	"self assert: (configuration countErrorsGiven: [ DataFrame new ]) equals: 30.
	self assert: (configuration countErrorsGiven: [ 
		(DataFrame withRows: #((Hi 0) (World 1)))
		rowNames: #(A B);
		columnNames: #(Greeting Integer) ]) equals: 23"
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWith [
	| ind1 ind2 offspring |
	ind1 := self node1.
	ind2 := self node2.
	self assert: ind1 print equals: 'self assert: arrayOfNames notEmpty'.
	self assert: ind2 print equals: 'self assert: arrayOfLastNames isEmpty'.
	offspring := (configuration crossover: ind1 with: ind2).
	self assertCollection: #('self assert: arrayOfNames isEmpty' 'self assert: arrayOfLastNames notEmpty') includesAny: (Array with: offspring print).
	"self assert: (configuration crossover: ind1 with: ind2) print equals: 'self assert: arrayOfNames empty'"
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWith1 [
	| individual1 individual2 offspring |
	GPRandom seed: 8.
	individual1 := self node3.
	individual2 := self node4.
	self assert: individual1 print equals: (RBParser parseExpression: 'self assert: (arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ])') formattedCode.
	self assert: individual2 print equals: 'self assert: arrayOfNames isEmpty'.
	offspring := configuration crossover: individual1 with: individual2.
	self assert: offspring print equals: (RBParser parseExpression: 'self assert: (arrayOfNames isEmpty and: [ arrayOfNames allSatisfy: #isString ])') formattedCode
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd [
	| individual1 individual2 children1 children2 |
	GPRandom seed: 758.
	individual1 := self node1.
	individual2 := self node4.
	children1 := individual1  withAllChildren allButFirst: 4.
	children2 := individual2 withAllChildren allButFirst: 4.
	self assert: 'self assert: arrayOfNames notEmpty' equals: individual1 print.
	self assert: 'self assert: arrayOfNames isEmpty' equals: individual2 print.
	self assert: children1 size equals: 2.
	self assert: children2 size equals: 2.
	self assertCollection: #('self assert: arrayOfNames notEmpty' 'self assert: arrayOfNames isEmpty') hasSameElements: ((1 to: 20) collect: [ :n | 
		 (configuration crossover: individual1 with: individual2 given: children1 and: children2) print
		]) asSet.
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateHaving [
	| individual1 individual2 |
	configuration random seed: 9.
	individual1 := self node1.
	individual2 := self node4.
	self assert: individual1 print equals: 'self assert: arrayOfNames notEmpty'.
	self assert: individual2 print equals: 'self assert: arrayOfNames isEmpty'.
	configuration mutate: (individual1 withAllChildren allButFirst: 4) having: (individual2 withAllChildren allButFirst: 4).
	self assert: individual1 print equals: 'self assert: arrayOfNames isEmpty'
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateWith [
	| individual1 individual2 |
	individual1 := self node1.
	individual2 := self node4.
	self assert: individual1 print equals: 'self assert: arrayOfNames notEmpty'.
	self assert: individual2 print equals: 'self assert: arrayOfNames isEmpty'.
	configuration mutate: individual1 with: individual2.
	self assert: individual1 print equals: 'self assert: arrayOfNames isEmpty'
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateWith1 [
	| individual1 individual2 |
	GPRandom seed: 8.
	individual1 := self node3.
	individual2 := self node4.
	self assert: individual1 print equals: (RBParser parseExpression: 'self assert: (arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ])') formattedCode.
	self assert: individual2 print equals: 'self assert: arrayOfNames isEmpty'.
	configuration mutate: individual1 with: individual2.
	self assert: individual1 print equals: (RBParser parseExpression: 'self assert: (arrayOfNames isEmpty and: [ arrayOfNames allSatisfy: #isString ])') formattedCode
]
