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

	"arrayOfNames notEmpty"

	^ GPNode new
		  id: #Method;
		  type: RBMessageNode;
		  depth: 1;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPLeafNode new
						    id: #Variable;
						    depth: 2;
						    nodeValue: 'arrayOfNames';
						    type: RBVariableNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   add: (GPSelectorNode new
						    id: #Message;
						    nodeValue: #notEmpty;
						    depth: 2;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node10 [

	"(arrayOfNames includes: aString) not"

	^ GPNode new
		  id: #NegativeInclusion;
		  depth: 0;
		  type: RBMessageNode;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPNode new
						    id: #Inclusion;
						    depth: 1;
						    type: RBMessageNode;
						    printBlock: [ :n :ctx | 
							    (n withAllChildren collect: #id) asArray asString ];
						    nodeChildren: (OrderedCollection new
								     add: (GPLeafNode new
										      id: #InstanceVar;
										      depth: 2;
										      nodeValue: 'arrayOfNames';
										      type: RBVariableNode;
										      printBlock: [ :n :ctx | n nodeValue asString ]);
								     add: (GPSelectorNode new
										      id: #Includes;
										      nodeValue: #includes:;
										      depth: 2;
										      printBlock: [ :n :ctx | n nodeValue ]);
								     add: (GPLeafNode new
										      id: #Variable;
										      nodeValue: #aString;
										      depth: 2;
										      type: RBVariableNode;
										      printBlock: [ :n :ctx | n nodeValue asString ]);
								     yourself);
						    nodeValue:
						    #( 'arrayOfNames' #includes: #aString ) asOrderedCollection);
				   add: (GPSelectorNode new
						    id: #Not;
						    nodeValue: #not;
						    depth: 1;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node2 [

	"arrayOfLastNames isEmpty"

	^ GPNode new
		  id: #Method;
		  type: RBMessageNode;
		  depth: 1;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPLeafNode new
						    id: #Variable;
						    depth: 2;
						    nodeValue: 'arrayOfLastNames';
						    type: RBVariableNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   add: (GPSelectorNode new
						    id: #Message;
						    nodeValue: #isEmpty;
						    depth: 2;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node3 [

	"arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ]"

	^ GPNode new
		  id: #Method;
		  type: RBMessageNode;
		  depth: 1;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPNode new
						    id: #Method;
						    depth: 2;
						    type: RBMessageNode;
						    printBlock: [ :n :ctx | 
							    (n withAllChildren collect: #id) asArray asString ];
						    nodeChildren: (OrderedCollection new
								     add: (GPLeafNode new
										      id: #Variable;
										      depth: 3;
										      nodeValue: 'arrayOfNames';
										      type: RBVariableNode;
										      printBlock: [ :n :ctx | n nodeValue asString ]);
								     add: (GPSelectorNode new
										      id: #Message;
										      nodeValue: #notEmpty;
										      depth: 3;
										      printBlock: [ :n :ctx | n nodeValue ]);
								     yourself);
						    nodeValue: #( 'arrayOfNames' #notEmpty ) asOrderedCollection);
				   add: (GPSelectorNode new
						    id: #And;
						    depth: 2;
						    nodeValue: #and:;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   add: (GPNode new
						    id: #Block;
						    depth: 2;
						    type: RBBlockNode;
						    printBlock: [ :n :ctx | 
							    (n withAllChildren collect: #id) asArray asString ];
						    nodeChildren: (OrderedCollection new
								     add: (GPNode new
										      id: #Method;
										      depth: 3;
										      type: RBMessageNode;
										      printBlock: [ :n :ctx | 
											      (n withAllChildren collect: #id) asArray asString ];
										      nodeChildren: (OrderedCollection new
												       add: (GPLeafNode new
														        id: #Variable;
														        depth: 4;
														        nodeValue: 'arrayOfNames';
														        type: RBVariableNode;
														        printBlock: [ :n :ctx | n nodeValue asString ]);
												       add: (GPSelectorNode new
														        id: #Satisfy;
														        nodeValue: #allSatisfy:;
														        depth: 4;
														        printBlock: [ :n :ctx | n nodeValue ]);
												       add: (GPLeafNode new
														        id: #Message;
														        nodeValue: #isString;
														        depth: 4;
														        type: RBLiteralNode;
														        printBlock: [ :n :ctx | n nodeValue asString ]);
												       yourself));
								     yourself);
						    nodeValue:
						    #( 'arrayOfNames' #allSatisfy: #isString )
							    asOrderedCollection);
				   yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node4 [

	"arrayOfNames isEmpty"

	^ GPNode new
		  id: #Method;
		  type: RBMessageNode;
		  depth: 1;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPLeafNode new
						    id: #Variable;
						    depth: 2;
						    nodeValue: 'arrayOfNames';
						    type: RBVariableNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   add: (GPSelectorNode new
						    id: #Message;
						    nodeValue: #isEmpty;
						    depth: 2;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node5 [

	"aNumber isInteger and: [ anumber positive ]"

	^ GPNode new
		  id: #Method;
		  type: RBMessageNode;
		  depth: 0;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPNode new
						    id: #Method;
						    depth: 1;
						    type: RBMessageNode;
						    printBlock: [ :n :ctx | 
							    (n withAllChildren collect: #id) asArray asString ];
						    nodeChildren: (OrderedCollection new
								     add: (GPLeafNode new
										      id: #Variable;
										      depth: 2;
										      nodeValue: 'aNumber';
										      type: RBVariableNode;
										      printBlock: [ :n :ctx | n nodeValue asString ]);
								     add: (GPSelectorNode new
										      id: #Message;
										      nodeValue: #isInteger;
										      depth: 3;
										      printBlock: [ :n :ctx | n nodeValue ]);
								     yourself);
						    nodeValue: #( 'aNumber' #isInteger ) asOrderedCollection);
				   add: (GPSelectorNode new
						    id: #And;
						    depth: 2;
						    nodeValue: #and:;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   add: (GPNode new
						    id: #Block;
						    depth: 2;
						    type: RBBlockNode;
						    printBlock: [ :n :ctx | 
							    (n withAllChildren collect: #id) asArray asString ];
						    nodeChildren: (OrderedCollection new
								     add: (GPNode new
										      id: #Method;
										      depth: 3;
										      type: RBMessageNode;
										      printBlock: [ :n :ctx | 
											      (n withAllChildren collect: #id) asArray asString ];
										      nodeChildren: (OrderedCollection new
												       add: (GPLeafNode new
														        id: #Variable;
														        depth: 4;
														        nodeValue: 'aNumber';
														        type: RBVariableNode;
														        printBlock: [ :n :ctx | n nodeValue asString ]);
												       add: (GPSelectorNode new
														        id: #Message;
														        nodeValue: #positive;
														        depth: 4;
														        printBlock: [ :n :ctx | n nodeValue ]);
												       yourself));
								     yourself);
						    nodeValue: #( 'aNumber' #positive ) asOrderedCollection);
				   yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node6 [

	"aNumber > 0"

	^ GPNode new
		  id: #Method;
		  type: RBMessageNode;
		  depth: 0;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPLeafNode new
						    id: #Variable;
						    depth: 2;
						    nodeValue: 'aNumber';
						    type: RBVariableNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   add: (GPSelectorNode new
						    id: #Comparison;
						    nodeValue: #>;
						    depth: 3;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   add: (GPLeafNode new
						    id: #Number;
						    depth: 2;
						    nodeValue: 0;
						    type: RBLiteralNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   yourself);
		  nodeValue: #( 'aNumber' #> '0' ) asOrderedCollection
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node7 [

	"aNumber == 0"

	^ GPNode new
		  id: #Method;
		  type: RBMessageNode;
		  depth: 0;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPLeafNode new
						    id: #Variable;
						    depth: 1;
						    nodeValue: 'aNumber';
						    type: RBVariableNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   add: (GPSelectorNode new
						    id: #Comparison;
						    nodeValue: #==;
						    depth: 1;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   add: (GPLeafNode new
						    id: #Number;
						    depth: 1;
						    nodeValue: 1;
						    type: RBLiteralNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   yourself);
		  nodeValue: #( 'aNumber' #== '1' ) asOrderedCollection
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node8 [

	"aNumber isInteger and: [ anumber positive and: [ aNumber isNumber ] ]"

	^ GPNode new
		  id: #Method;
		  type: RBMessageNode;
		  depth: 0;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPNode new
						    id: #Method;
						    depth: 1;
						    type: RBMessageNode;
						    printBlock: [ :n :ctx | 
							    (n withAllChildren collect: #id) asArray asString ];
						    nodeChildren: (OrderedCollection new
								     add: (GPLeafNode new
										      id: #Variable;
										      depth: 2;
										      nodeValue: 'aNumber';
										      type: RBVariableNode;
										      printBlock: [ :n :ctx | n nodeValue asString ]);
								     add: (GPSelectorNode new
										      id: #Message;
										      nodeValue: #isInteger;
										      depth: 3;
										      printBlock: [ :n :ctx | n nodeValue ]);
								     yourself);
						    nodeValue: #( 'aNumber' #isInteger ) asOrderedCollection);
				   add: (GPSelectorNode new
						    id: #And;
						    depth: 2;
						    nodeValue: #and:;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   add: (GPNode new
						    id: #Block;
						    depth: 2;
						    type: RBBlockNode;
						    printBlock: [ :n :ctx | 
							    (n withAllChildren collect: #id) asArray asString ];
						    nodeChildren: (OrderedCollection new
								     add: (GPNode new
										      id: #Method;
										      depth: 3;
										      type: RBMessageNode;
										      printBlock: [ :n :ctx | 
											      (n withAllChildren collect: #id) asArray asString ];
										      nodeChildren: (OrderedCollection new
												       add: (GPNode new
														        id: #Method;
														        depth: 3;
														        type: RBMessageNode;
														        printBlock: [  ];
														        nodeChildren: (OrderedCollection new
																         add: (GPLeafNode new
																		          id: #Variable;
																		          depth: 4;
																		          nodeValue: 'aNumber';
																		          type: RBVariableNode;
																		          printBlock: [ :n :ctx | 
																			          n nodeValue asString ]);
																         add: (GPSelectorNode new
																		          id: #Message;
																		          nodeValue: #positive;
																		          depth: 4;
																		          printBlock: [ :n :ctx | n nodeValue ]);
																         yourself));
												       add: (GPSelectorNode new
														        id: #And;
														        depth: 2;
														        nodeValue: #and:;
														        printBlock: [ :n :ctx | n nodeValue ]);
												       add: (GPNode new
														        id: #Block;
														        depth: 2;
														        type: RBBlockNode;
														        printBlock: [ :n :ctx | 
															        (n withAllChildren collect: #id) asArray
																        asString ];
														        nodeChildren: (OrderedCollection new
																         add: (GPNode new
																		          id: #Method;
																		          depth: 3;
																		          type: RBMessageNode;
																		          printBlock: [ :n :ctx | 
																			          (n withAllChildren collect: #id) asArray
																				          asString ];
																		          nodeChildren: (OrderedCollection new
																				           add: (GPLeafNode new
																						            id: #Variable;
																						            depth: 4;
																						            nodeValue: 'aNumber';
																						            type: RBVariableNode;
																						            printBlock: [ :n :ctx | 
																							            n nodeValue asString ]);
																				           add: (GPSelectorNode new
																						            id: #Message;
																						            nodeValue: #isNumber;
																						            depth: 4;
																						            printBlock: [ :n :ctx | n nodeValue ]);
																				           yourself));
																         yourself);
														        nodeValue:
														        #( 'aNumber' #isNumber ) asOrderedCollection);
												       yourself));
								     yourself));
				   yourself)
]

{ #category : #'as yet unclassified' }
GPAssertConfigurationTest >> node9 [

	"arrayOfLastNames includes: aString"

	^ GPNode new
		  id: #Inclusion;
		  depth: 0;
		  type: RBMessageNode;
		  printBlock: [ :n :ctx | n ast formattedCode ];
		  nodeChildren: (OrderedCollection new
				   add: (GPLeafNode new
						    id: #InstanceVar;
						    depth: 1;
						    nodeValue: 'arrayOfLastNames';
						    type: RBVariableNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   add: (GPSelectorNode new
						    id: #Includes;
						    nodeValue: #includes:;
						    depth: 1;
						    printBlock: [ :n :ctx | n nodeValue ]);
				   add: (GPLeafNode new
						    id: #Variable;
						    nodeValue: #aString;
						    depth: 1;
						    type: RBVariableNode;
						    printBlock: [ :n :ctx | n nodeValue asString ]);
				   yourself);
		  nodeValue:
		  #( 'arrayOfNames' #includes: #aString ) asOrderedCollection
]

{ #category : #initialization }
GPAssertConfigurationTest >> setUp [
	configuration := GPAssertConfiguration new seed: 1345.
	configuration buildGrammar 
]

{ #category : #tests }
GPAssertConfigurationTest >> testCountErrorsGiven [
	configuration seed: 3.
	configuration options: (OrderedCollection new 
		addAll: #(1 2 -2 4 $e $r $, 'asdf' nil #(Greeting Integer));
		"add: [ :obj | obj isArray and: [ obj allSatisfy: #isString ] ];"
		yourself);
	"configuration options: #(1 2 -2 4 $e $r $, 'asdf' nil #(Greeting Integer));"
		targetSelector: #sum:;
		targetClass: GPDigit.
	self assert: (configuration countErrorsGiven: [ GPDigit new ]) equals: 100.
	self assert: (configuration countErrorsGiven: [ GPDigit new value: 4 ]) equals: 58.
	"self assert: (configuration countErrorsGiven: [ DataFrame new ]) equals: 30.
	self assert: (configuration countErrorsGiven: [ 
		(DataFrame withRows: #((Hi 0) (World 1)))
		rowNames: #(A B);
		columnNames: #(Greeting Integer) ]) equals: 23"
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverBetweenWith [

	| individual1 individual2 offspring |
	configuration seed: 8.
	individual1 := self node7.
	individual2 := self node6.
	self
		assert: individual1 print
		equals: (RBParser parseExpression: 'aNumber == 1') formattedCode.
	self
		assert: individual2 print
		equals: (RBParser parseExpression: 'aNumber > 0') formattedCode.
	offspring := configuration
		             crossoverBetween: individual1
		             with: individual2.
	self
		assert: offspring print
		equals: 'aNumber == 1 and: [ aNumber > 0 ]'
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd1 [
	| individual1 individual2  offspring1 offspring2 |
	configuration seed: 758.
	individual1 := self node1.
	individual2 := self node4.
	offspring1 := individual1 deepCopy.
	self assert: offspring1 print equals: 'arrayOfNames notEmpty'.
	offspring1 := configuration crossover: offspring1 with: individual2 given: offspring1 withAllChildren and: individual2 withAllChildren.
	self assert: offspring1 print equals: 'arrayOfNames isEmpty'.
	offspring2 := individual2 deepCopy.
	self assert: offspring2 print equals: 'arrayOfNames isEmpty'.
	offspring2 := configuration crossover: offspring2 with: individual1 given: offspring2 withAllChildren and: individual1 withAllChildren.
	self assert: offspring2 print equals: 'arrayOfNames notEmpty' 
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd10 [

	| individual1 individual2 set |
	configuration seed: 87567.
	individual1 := self node9.
	individual2 := self node10.
	self
		assert: individual1 print
		equals: 'arrayOfLastNames includes: aString'.
	self
		assert: individual2 print
		equals: '(arrayOfNames includes: aString) not'.
	set := ((1 to: 300) collect: [ :i | 
		        | offspring |
		        offspring := individual1 deepCopy.
		        offspring := configuration
			                     crossover: offspring
			                     with: individual2
			                     given: offspring withAllChildren
			                     and: individual2 withAllChildren.
		        offspring ifNil: [ offspring ] ifNotNil: [ offspring print ] ])
		       asSet.
	self assert: set size >= 2.
	self
		assertCollection: set
		includesAny:
			#( 'arrayOfNames includes: aString'
			   "'(arrayOfNames includes: aString) not'
			   'arrayOfLastNames includes: aString'" )
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd11 [
	| individual1 individual2 set |
	configuration seed: 8.
	individual1 := self node9.
	individual2 := self node10.
	self assert: individual1 print equals: 'arrayOfLastNames includes: aString'.
	self assert: individual2 print equals: '(arrayOfNames includes: aString) not'.
	set := ((1 to: 300) collect: [ :i | | offspring |
		offspring := individual2 deepCopy.
		offspring := configuration crossover: offspring with: individual1 given: offspring withAllChildren and: individual1 withAllChildren.
		offspring ifNil: [ offspring ] ifNotNil: [ offspring print ] ]) asSet.
	self assert: set size >= 2.
	self assertCollection: set includesAny: #('(arrayOfLastNames includes: aString) not' '(arrayOfNames includes: aString) not' "'arrayOfLastNames includes: aString'")
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd2 [
	| individual1 individual2  offspring1 offspring2 |
	configuration seed: 758.
	individual1 := self node1.
	individual2 := self node2.
	offspring1 := individual1 deepCopy.
	self assert: offspring1 print equals: 'arrayOfNames notEmpty'.
	offspring1 := configuration crossover: offspring1 with: individual2 given: offspring1 withAllChildren allButFirst and: individual2 withAllChildren.
	self assert: offspring1 print equals: 'arrayOfNames isEmpty'.
	offspring2 := individual2 deepCopy.
	self assert: offspring2 print equals: 'arrayOfLastNames isEmpty'.
	offspring2 := configuration crossover: offspring2 with: individual1 given: offspring2 withAllChildren and: individual1 withAllChildren.
	self assert: offspring2 print equals: 'arrayOfLastNames notEmpty' 
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd3 [
	| individual1 individual2 offspring |
	configuration seed: 8.
	individual1 := self node3.
	individual2 := self node4.
	offspring := individual1 deepCopy.
	self assert: offspring print equals: (RBParser parseExpression: 'arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ]') formattedCode.
	offspring := configuration crossover: offspring with: individual2 given: offspring withAllChildren  and: individual2 withAllChildren.
	self assert: offspring print equals: (RBParser parseExpression: 'arrayOfNames isEmpty and: [ arrayOfNames allSatisfy: #isString ]') formattedCode.
	offspring := individual2 deepCopy.
	self assert: offspring print equals: (RBParser parseExpression: 'arrayOfNames isEmpty') formattedCode.
	offspring := configuration crossover: offspring with: individual1 given: offspring withAllChildren and: individual1 withAllChildren.
	self assert: offspring print equals: (RBParser parseExpression: 'arrayOfNames isString') formattedCode
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd4 [
	| individual1 individual2 set |
	configuration seed: 8.
	individual1 := self node3.
	individual2 := self node4.
	self assert: individual1 print equals: (RBParser parseExpression: 'arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ]') formattedCode.
	set := ((1 to: 300) collect: [ :n | | offspring |
		offspring := individual1 deepCopy.
		offspring := configuration crossover: offspring with: individual2 given: offspring withAllChildren allButFirst and: individual2 withAllChildren.
		offspring print ]) asSet.
	self assert: set size equals: 3.
	self assertCollection: set hasSameElements: #('arrayOfNames isEmpty and: [ arrayOfNames allSatisfy: #isString ]' 'arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isEmpty ]' 'arrayOfNames notEmpty and: [ arrayOfNames isEmpty ]')
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd5 [
	| individual1 individual2 set |
	configuration seed: 8.
	individual1 := self node3.
	individual2 := self node4.
	self assert: individual1 print equals: (RBParser parseExpression: 'arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ]') formattedCode.
	self assert: individual2 print equals: (RBParser parseExpression: 'arrayOfNames isEmpty') formattedCode.
	set := ((1 to: 300) collect: [ :n | | offspring |
		offspring := individual2 deepCopy.
		offspring := configuration crossover: offspring with: individual1 given: offspring withAllChildren allButFirst and: individual1 withAllChildren.
		offspring print ]) asSet.
	self assert: set size equals: 2.
	self assertCollection: set hasSameElements: #('arrayOfNames notEmpty' 'arrayOfNames isString')
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd6 [
	| individual1 individual2 set |
	configuration seed: 8.
	individual1 := self node5.
	individual2 := self node6.
	self assert: individual1 print equals: (RBParser parseExpression: 'aNumber isInteger and: [ aNumber positive ]') formattedCode.
	self assert: individual2 print equals: (RBParser parseExpression: 'aNumber > 0') formattedCode.
	set := ((1 to: 300) collect: [ :n | | offspring |
		offspring := individual1 deepCopy.
		offspring := configuration crossover: offspring with: individual2 given: offspring withAllChildren and: individual2 withAllChildren.
		offspring print ]) asSet.
	self assert: set size equals: 2.
	self assertCollection: set hasSameElements: #('aNumber > 0 and: [ aNumber positive ]' 'aNumber isInteger and: [ aNumber > 0 ]')
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd7 [

	| individual1 individual2 col |
	configuration seed: 8.
	individual1 := self node5.
	individual2 := self node6.
	self assert: individual1 print equals: (RBParser parseExpression:
			 'aNumber isInteger and: [ aNumber positive ]') formattedCode.
	self
		assert: individual2 print
		equals: (RBParser parseExpression: 'aNumber > 0') formattedCode.
	col := (1 to: 300) collect: [ :i | 
		       | offspring |
		       offspring := individual2 deepCopy.
		       offspring := configuration
			                    crossover: offspring
			                    with: individual1
			                    given: offspring withAllChildren
			                    and: individual1 withAllChildren.
		       offspring "printBlock: [ :n :ctx | n ast formattedCode ]" ].
	self assert: (col allSatisfy: #notNil)
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd8 [
	| individual1 individual2 set |
	configuration seed: 8.
	individual1 := self node6.
	individual2 := self node7.
	self assert: individual1 print equals: 'aNumber > 0'.
	self assert: individual2 print equals: 'aNumber == 1'.
	set := ((1 to: 300) collect: [ :i | | offspring |
		offspring := individual1 deepCopy.
		offspring := configuration crossover: offspring with: individual2 given: offspring withAllChildren allButFirst and: individual2 withAllChildren.
		offspring print ]) asSet.
	self assert: set size equals: 2.
	self assertCollection: set hasSameElements: #('aNumber > 1' 'aNumber == 0')
]

{ #category : #tests }
GPAssertConfigurationTest >> testCrossoverWithGivenAnd9 [
	| individual1 individual2 set |
	configuration seed: 8.
	individual1 := self node6.
	individual2 := self node8.
	self assert: individual1 print equals: 'aNumber > 0'.
	self assert: individual2 print equals: 'aNumber isInteger and: [ aNumber positive and: [ aNumber isNumber ] ]'.
	set := ((1 to: 300) collect: [ :i | | offspring |
		offspring := individual2 deepCopy.
		offspring := configuration crossover: offspring with: individual1 given: offspring withAllChildren and: individual1 withAllChildren.
		offspring print ]) asSet.
	self assert: set size equals: 4.
	self assertCollection: set hasSameElements: (Array 
		with: (RBParser parseExpression: 'aNumber > 0 and: [ aNumber positive and: [ aNumber isNumber ] ]') formattedCode
		with: (RBParser parseExpression: 'aNumber isInteger and: [ aNumber > 0 and: [ aNumber isNumber ] ]') formattedCode
		with: (RBParser parseExpression: 'aNumber isInteger and: [ aNumber positive and: [ aNumber > 0 ] ]') formattedCode
		with: (RBParser parseExpression: 'aNumber isInteger and: [ aNumber > 0 ]') formattedCode)
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateHaving [
	| individual1 individual2 |
	configuration random seed: 9.
	individual1 := self node1.
	individual2 := self node4.
	self assert: individual1 print equals: 'arrayOfNames notEmpty'.
	self assert: individual2 print equals: 'arrayOfNames isEmpty'.
	configuration mutate: individual1 withAllChildren allButFirst having: individual2 withAllChildren.
	self assert: individual1 print equals: 'arrayOfNames isEmpty'
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateHaving2 [
	| individual1 individual2 set |
	configuration seed: 8.
	individual1 := self node5.
	individual2 := self node6.
	self assert: individual1 print equals: (RBParser parseExpression: 'aNumber isInteger and: [ aNumber positive ]') formattedCode.
	self assert: individual2 print equals: (RBParser parseExpression: 'aNumber > 0') formattedCode.
	set := ((1 to: 300) collect: [ :i |
		individual1 := self node5.
		configuration mutate: individual1 withAllChildren allButFirst having: individual2 withAllChildren.
		individual1 print ]) asSet.
	self assert: set size equals: 2.
	self assertCollection: set hasSameElements: #('aNumber > 0 and: [ aNumber positive ]' 'aNumber isInteger and: [ aNumber > 0 ]')
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateHaving3 [
	| individual1 individual2 set |
	configuration seed: 8.
	individual1 := self node5.
	individual2 := self node6.
	self assert: individual1 print equals: (RBParser parseExpression: 'aNumber isInteger and: [ aNumber positive ]') formattedCode.
	self assert: individual2 print equals: (RBParser parseExpression: 'aNumber > 0') formattedCode.
	set := ((1 to: 300) collect: [ :i |
		individual2 := self node6.
		configuration mutate: individual2 withAllChildren allButFirst having: individual1 withAllChildren.
		individual2 print ]) asSet.
	self assert: set size equals: 1.
	self assert: set asArray first equals: 'aNumber > 0'
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateLeafNodesOf [

	| individual1 set |
	configuration seed: 9.
	individual1 := self node1.
	self assert: individual1 print equals: 'arrayOfNames notEmpty'.
	set := ((1 to: 300) collect: [ :n | 
		        individual1 := self node1.
		        configuration mutateLeafNodesOf: individual1.
		        individual1 nodeChildren second print ]) asSet.
	self assert: set size equals: 19.
	self
		assertCollection: set
		includesAll:
			#( #isString #isInteger #isFloat #isNumber #isFinite #isCharacter
			   #isCollection #isArray #isSymbol #isColor #isBlock #isEmpty
			   #notEmpty #isNil #notNil #positive #negative #isPoint )
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateWith [
	| individual1 individual2 |
	individual1 := self node1.
	individual2 := self node4.
	self assert: individual1 print equals: 'arrayOfNames notEmpty'.
	self assert: individual2 print equals: 'arrayOfNames isEmpty'.
	configuration mutate: individual1 with: individual2.
	self assert: individual1 print equals: 'arrayOfNames isEmpty'
]

{ #category : #tests }
GPAssertConfigurationTest >> testMutateWith1 [
	| individual1 individual2 |
	configuration seed: 8.
	individual1 := self node3.
	individual2 := self node4.
	self assert: individual1 print equals: (RBParser parseExpression: 'arrayOfNames notEmpty and: [ arrayOfNames allSatisfy: #isString ]') formattedCode.
	self assert: individual2 print equals: 'arrayOfNames isEmpty'.
	configuration mutate: individual1 with: individual2.
	self assert: individual1 print equals: (RBParser parseExpression: 'arrayOfNames isEmpty and: [ arrayOfNames allSatisfy: #isString ]') formattedCode
]

{ #category : #tests }
GPAssertConfigurationTest >> testReplaceByNodeOfIndividualByGiven [
	| individual1 individual2 col |
	configuration seed: 8.
	individual1 := self node5.
	individual2 := self node6.
	self assert: individual1 print equals: (RBParser parseExpression: 'aNumber isInteger and: [ aNumber positive ]') formattedCode.
	self assert: individual2 print equals: (RBParser parseExpression: 'aNumber > 0') formattedCode.
	col := ((1 to: 300) collect: [ :i | | offspring |
		offspring := individual2 deepCopy.
		offspring := configuration replaceByNode: individual2 withAllChildren of: individual2 by: individual1 withAllChildren given: individual2.
		offspring printBlock: [ :n :ctx | n ast formattedCode ].
		offspring print ]) asSet.
	self assertCollection: col hasSameElements: #('aNumber isInteger' 'aNumber positive')
]
