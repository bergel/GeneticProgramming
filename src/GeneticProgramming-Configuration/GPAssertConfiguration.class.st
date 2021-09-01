Class {
	#name : #GPAssertConfiguration,
	#superclass : #GPConfiguration,
	#instVars : [
		'targetClass',
		'testClasses',
		'targetSelector',
		'originalMethod',
		'options',
		'grammar',
		'targetSelectors',
		'builder',
		'index',
		'contextBlocks',
		'numberOfFailures',
		'assocs',
		'randomIterations'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #adding }
GPAssertConfiguration >> addOptionArgs: symbols [
	grammar ifNil: [ self buildGrammar ].
	grammar addOptions: symbols forCollectionOptionsBeginWith: #Args
]

{ #category : #adding }
GPAssertConfiguration >> addOptionSelectors: selectors [
	selectors ifEmpty: [ ^ self ].
	grammar ifNil: [ self buildGrammar ].
	(selectors groupedBy: #numArgs) 
		associationsDo: [ :assoc | 
			grammar addOrReplaceSelectorRule: 
				(assoc key = 0 
					ifTrue: [ #Message ] 
					ifFalse: [ #Message, assoc key asString ] ) withValues: assoc value ]
]

{ #category : #adding }
GPAssertConfiguration >> addTargetVariable [ 
	| vals |
	self assert: grammar notNil.
	self assert: targetSelector notNil.
	self assert: builder notNil.
	vals := builder argumentsOf: targetSelector.
	self assert: (vals notNil and: [ vals notEmpty ]).
	"self assert: index <= vals size."
	grammar createOrReplaceLeafRule: #Variable ofClass: RBVariableNode withValues: vals "(Array with: (vals at: index))"
]

{ #category : #adding }
GPAssertConfiguration >> addVariableRule: symbol withValues: collection [
	grammar ifNil: [ self buildGrammar ].
	self assert: (grammar ruleOptionOf: symbol) isNil.
	self assert: (collection isCollection and: [ collection notEmpty ]).
	grammar addLeafRule: symbol ofClass: RBVariableNode withValues: collection
]

{ #category : #adding }
GPAssertConfiguration >> argumentTypes: classes [
	| classNames |
	self assert: (classes notEmpty and: [ classes allSatisfy: #isClass ]).
	grammar ifNil: [ self buildGrammar ].
	classNames := classes collect: #name.
	grammar addOptions: classNames asSet asOrderedCollection forLeafRule: #Class
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> betterChildBetween: newC1 and: newC2 given: array [

	| node |
	node := (newC1 notNil and: [ newC2 notNil ])
		        ifTrue: [ self getBestBetween: newC1 and: newC2 ]
		        ifFalse: [ 
		        (Array with: newC1 with: newC2)
			        detect: #notNil
			        ifNone: [ ^ nil ] ].
	array do: [ :parent | node addParent: parent ].
	^ node
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> buildGrammar [
	"self assert: targetClass notNil."
	grammar := targetClass 
		ifNil: [ builder buildAssertionGrammar ] 
		ifNotNil: [ builder buildAssertionGrammar: self targetSelectors of: targetClass ].
	grammar seed: random seed.
	"grammar := builder buildAssertionGrammar: targetClass of: self targetSelectors."
	grammar configuration: self
	
]

{ #category : #accessing }
GPAssertConfiguration >> contextBlocks: collection [
	self assert: (collection isCollection).
	contextBlocks := collection
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> countErrors [
	self assert: targetClass notNil.
	self assert: targetSelector notNil.
	^ contextBlocks 
		ifEmpty: [ [ self countErrorsGiven: [ targetClass new ] ] on: Exception do: [ randomIterations ] ] 
		ifNotEmpty: [ [(contextBlocks collect: [ :block | 
				self countErrorsGiven: block ]) min] on: Exception do: [ randomIterations ] ]
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> countErrorsGiven: block [

	| res rm |
	self assert: block isBlock.
	rm := GPRandom seed: 10.
	res := (1 to: randomIterations) inject: 0 into: [ :sum :num | 
		       | args |
		       args := (1 to: targetSelector numArgs) collect: [ :a | 
			               rm randomlySelect: options ].
		       sum + ([ 
		        block value perform: targetSelector withArguments: args.
		        0 ]
			        on: Exception
			        do: [ :e | "Transcript show: individual print, String cr, args asString, String cr, e class name, '->', e messageText, String cr."
				        e class == AssertionFailure
					        ifTrue: [ 0 ]
					        ifFalse: [ 
						        1 "e class == MessageNotUnderstood 
					ifTrue: [ 0 ] 
					ifFalse: [ 1 ]" ] ]) ].
	^ res
]

{ #category : #operations }
GPAssertConfiguration >> createNewIndividual [	
	^ self newFunction
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> crossover: individual between: children1 and: children2 [
	| ids childIds indexes shuffledIds |
	ids := children1 collect: #id.
	childIds := children2 collect: #id.
	shuffledIds := random shuffleElementsOf: ids copy.
	shuffledIds 
		detect: [ :nodeId |
			indexes := random shuffleElementsOf: (individual indexesOf: nodeId on: childIds).
			indexes notEmpty ] 
		ifFound: [ :nodeId | 
			(children1 at: (random randomlySelect: (individual indexesOf: nodeId on: ids))) replaceBy: (children2 at: (random randomlySelect: indexes)) deepCopy.
			^ individual ].
	^ nil
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> crossover: individual1 with: individual2 [

	| number |
	number := random randomNumber: 100.

	^ number < 50
		  ifTrue: [ self crossoverBetween: individual1 with: individual2 ]
		  ifFalse: [ self crossoverJoining: individual1 with: individual2 ]

	"^ self crossoverBetween: individual1 with: individual2"
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> crossover: individual with: individual2 given: children1 and: children2 [
	| indiv |
	indiv := (self replaceByIdAny: children1 allButFirst of: individual by: children2 given: individual2)
		ifTrue: [ individual ] 
		ifFalse: [ self replaceByNode: children1 of: individual by: children2 given: individual2 ].
	indiv ifNotNil: [ indiv printBlock: [ :n :ctx | n ast formattedCode ] ].
	^ indiv
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> crossoverBetween: individual1 with: individual2 [

	| offspring1 offspring2 |
	offspring1 := individual1 deepCopy.
	offspring1 := self
		              crossover: offspring1
		              with: individual2
		              given: offspring1 withAllChildren
		              and: individual2 withAllChildren.
	offspring1 ifNotNil: [ offspring1 addParent: individual1 ].
	offspring2 := individual2 deepCopy.
	offspring2 := self
		              crossover: offspring2
		              with: individual1
		              given: offspring2 withAllChildren
		              and: individual1 withAllChildren.
	offspring2 ifNotNil: [ offspring2 addParent: individual2 ].
	^ (offspring1 notNil and: [ offspring2 notNil ])
		  ifTrue: [ 
			  (self distanceFromSolutionOf: offspring1)
			  < (self distanceFromSolutionOf: offspring2)
				  ifTrue: [ offspring1 ]
				  ifFalse: [ 
					  offspring1 fitness = offspring2 fitness
						  ifTrue: [ 
						  random randomlySelect:
							  (Array with: offspring1 with: offspring2) ]
						  ifFalse: [ offspring2 ] ] ]
		  ifFalse: [ 
			  (Array with: offspring1 with: offspring2)
				  detect: #notNil
				  ifNone: [ nil ] ]
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> crossoverJoining: individual1 with: individual2 [

	| o1 o2 node1 node2 |
	o1 := self randomSubTree: individual1 given: #Method.
	o2 := self randomSubTree: individual2 given: #Method.
	node1 := self newTreeOf: o1 deepCopy and: o2 deepCopy.
	node1 ifNotNil: [ 
		node1
			addParent: individual1;
			addParent: individual2 ].
	node2 := self newTreeOf: o2 deepCopy and: o1 deepCopy.
	node2 ifNotNil: [ 
		node2
			addParent: individual1;
			addParent: individual2 ].
	^ self
		  betterChildBetween: node1
		  and: node2
		  given: (Array with: individual1 with: individual2)
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> crossoverOfType: individual with: individual2 given: children1 and: children2 [
	| types1 types2 typesSet |
	types1 := (children1 collectWithIndex: [:ch :ind | 
		(ch type -> ch class) -> (ch id -> ind) ]) 
		reject: [:assoc | assoc value key = #Variable ].
	types2 := (children2 collectWithIndex: [:ch :ind | 
		(ch type -> ch class) -> (ch id -> ind) ])
		reject: [:assoc | assoc value key = #Variable ].
	typesSet := (types1 collect: #key) asSet asOrderedCollection.
	assocs := typesSet
		collect: [ :assoc | | indexes |
			indexes := types2 
				select: [ :ass | ass key = assoc ]
				thenCollect: [ :ass | ass value value ].
			assoc -> indexes ]
		thenReject: [ :assoc | assoc value isEmpty ].
	assocs ifNotEmpty: [ | assoc node indexes |
		individual addParent: individual2.
		assoc := random randomlySelect: assocs.
		indexes := types1 
			select: [:ass | ass key = assoc key ]
			thenCollect: [:ass | ass value value ].
		node := children1 at: (random randomlySelect: indexes).
		node replaceBy: (children2 at: (random randomlySelect: assoc value value)) deepCopy.
		^ individual 
	].
	^ nil
]

{ #category : #operations }
GPAssertConfiguration >> distanceFromSolutionOf: individual [
	| testResults e uninstalled wTest fitnessFunction |
	"weight for each unit test -> wTest = 100/nTests, nTests = total unit tests
	tErrors = nTestErrors * wTest * (2/3),            2/3 is the percentage value of importance
	rErrors = (nTests/nIterations) * nRandomErrors * wTest * (1/3),   nIterations -> number of iterations of count errors"
	self assert: targetClass notNil.
	self assert: (testClasses notEmpty and: [ testClasses allSatisfy: #isClass ]).
	uninstalled := false.
	[ self injectIntoMethod: individual ] on: Exception do: [ 
		uninstalled := true.
		self uninstall.
	].
	e := self countErrors.
	testResults := testClasses collect: [ :testClass | testClass buildSuite run ].
	wTest := 100/(testResults collect: #runCount) sum.
	fitnessFunction := GPAssertionFitnessFunction new.
	fitnessFunction 
		objectiveAt: 'nRandomErrors' put: (uninstalled ifTrue: [ randomIterations ] ifFalse: [ e ]);
		objectiveAt: 'nTestErrors' put: (uninstalled ifTrue: [ (testResults collect: #runCount) sum ] ifFalse: [ (testResults collect: [ :tR | tR failureCount + tR errorCount]) sum ]);
		weightAt: 'nRandomErrors' put: ((testResults collect: #runCount) sum / randomIterations) * wTest * (1/3);
		weightAt: 'nTestErrors' put: wTest * (2/3).
	individual fitness: fitnessFunction.
	self uninstall.
	^ individual fitness
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> getBestBetween: object1 and: object2 [

	object1 fitness ifNil: [ self distanceFromSolutionOf: object1 ].
	object2 fitness ifNil: [ self distanceFromSolutionOf: object2 ].
	^ object1 fitness < object2 fitness
		  ifTrue: [ object1 ]
		  ifFalse: [ 
			  object2 fitness < object1 fitness
				  ifTrue: [ object2 ]
				  ifFalse: [ 
				  random randomlySelect: (Array with: object1 with: object2) ] ]
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> getGrammarNodeOptions [
	^ (grammar options associations 
			collect: [ :assoc | assoc key -> (assoc value nodeOptions) ]
			thenSelect: [ :assoc | assoc value notEmpty ]) asDictionary
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> getNodeIdOptions: dictionary given: nodeId and: ids [
	| col |
	col := OrderedCollection new.
	dictionary at: nodeId 
		ifPresent: [ :nodeIds | 
			col addAll: (nodeIds 
				collect: [ :id | ids indexOf: id ]
				thenSelect: [ :ind | ind > 0 ]) ]
		ifAbsent: [ dictionary associations
			select: [ :assoc | assoc value includes: nodeId ]
			thenDo: [ :assoc | | i |
				i := ids indexOf: assoc key.
				i > 0 ifTrue: [ col add: i ] ] ].
	^ col
]

{ #category : #accessing }
GPAssertConfiguration >> index: number [
	self assert: (number isNumber and: [ number > 0 ]).
	index := number
]

{ #category : #initialization }
GPAssertConfiguration >> initialize [ 
	super initialize.
	builder := GPAssertionGrammarBuilder new.
	options := OrderedCollection new.
	targetSelectors := OrderedCollection new.
	contextBlocks := OrderedCollection new.
	numberOfFailures := 0.
	randomIterations := 100
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> injectIntoMethod: individual [

	| aBehavior rbMethodNode ast |
	self assert: targetSelector notNil.
	self assert: targetClass notNil.
	aBehavior := targetClass instanceSide.
	originalMethod := aBehavior compiledMethodAt: targetSelector. "targetClass methodNamed: targetSelector."
	rbMethodNode := RBParser parseMethod: originalMethod sourceCode.
	"ast := RBParser parseExpression: 'self assert: ' , individual print."
	ast := RBMessageNode new
		       receiver: (RBVariableNode named: 'self');
		       selector: #assert:;
		       arguments: (OrderedCollection new
				        add: individual ast;
				        yourself).
	rbMethodNode body addNodeFirst: ast.
	"copy := originalMethod copy.
	copy ast body addNodeFirst: individual ast."
	targetClass compile: rbMethodNode printString notifying: nil
	"aBehavior methodDict at: targetSelector put: copy."
]

{ #category : #operations }
GPAssertConfiguration >> mutate: individual [
	| number newIndividual |
	number := random randomNumber: 100.
	number <= 50 
		ifTrue: [ newIndividual := self newTerminal.
			self mutate: individual withAllChildren having: newIndividual withAllChildren ]
		ifFalse: [ self mutateLeafNodesOf: individual ]
	"newIndividual := self newTerminal.
	self mutate: individual with: self newTerminal."
]

{ #category : #operations }
GPAssertConfiguration >> mutate: children1 having: children2 [
	| ids childIds |
	ids := children1 collect: #id.
	childIds := children2 collect: #id.
	"nodeOptions := self getGrammarNodeOptions. "
	assocs := ids asSet asOrderedCollection 
		collect: [ :nodeId | | inds |
			inds := GPAbstractNode indexesOf: nodeId on: childIds.
			"inds addAll: (self getNodeIdOptions: nodeOptions given: nodeId and: childIds)."
			nodeId -> inds ]
		thenReject: [ :assoc | 
			assoc value isEmpty or: [ assoc key = #Variable ] ].
	assocs ifNotEmpty: [ | assoc node r |
		assoc := random randomlySelect: assocs.
		node := children1 at: (random randomlySelect: (GPAbstractNode indexesOf: assoc key on: ids)).
		r := (children2 at: (random randomlySelect: assoc value)) deepCopy.
		"Transcript show: 'mutation:', node print, ' replaced by: ', r print, String cr. "
		node replaceBy: r.
	].
]

{ #category : #operations }
GPAssertConfiguration >> mutate: individual with: source [
	| children indivIds sceChildren sourceIds nodeToMutate node |
	children := random shuffleElementsOf: (individual withAllChildren allButFirst).
	indivIds := children collect: #id.
	sceChildren := source withAllChildren.
	sourceIds := sceChildren collect: #id.
	(indivIds includesAny: sourceIds) ifFalse: [ ^ self ].
	nodeToMutate := children at: (indivIds indexOfAnyOf: sourceIds).
	node := sceChildren at: (sourceIds indexOf: nodeToMutate id).
	nodeToMutate replaceBy: node
]

{ #category : #operations }
GPAssertConfiguration >> mutateLeafNodesOf: individual [ 
	| nodes node values |
	nodes := individual withAllChildren select: [ :ind | (ind isSelectorNode or: [ ind isLeafNode ]) and: [ ind id ~= #Variable ] ].
	node := random randomlySelect: nodes.
	values := (grammar ruleOptionOf: node id) nodes flatCollect: #value.
	node nodeValue: (random randomlySelect: values)
]

{ #category : #hooks }
GPAssertConfiguration >> newFunction [ 
	| node found i |
	found := false.
	i := 0.
	grammar := self updateGrammar.
	[ found or: [ i > 100 ] ] whileFalse: [ 
		depthModified ifFalse: [ depth := random randomNumber: 5 ].
		self assert: depth notNil.
		grammar 
			methodName: (random randomlySelect: #(#full #grow));
			configuration: self.
		node := grammar expandTree: #Method.
		found := node isNotNil.
		i := i + 1. ].
	node ifNotNil: [
		node evaluationBlock: [ :n :ctx | n ast ];
			printBlock: [ :n :ctx | n ast formattedCode ] ]
		ifNil: [ ^ nil ].
	^ node
]

{ #category : #'instance creation' }
GPAssertConfiguration >> newNodeOfRule: symbol1 and: symbol2 [

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
						    nodeChildren: OrderedCollection new);
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
										      nodeChildren: OrderedCollection new);
								     yourself));
				   yourself)
]

{ #category : #hooks }
GPAssertConfiguration >> newTerminal [
	^ self newFunction 
]

{ #category : #'instance creation' }
GPAssertConfiguration >> newTreeOf: node1 and: node2 [

	| node |
	node := self newNodeOfRule: #Method and: #And.
	grammar
		updateNodeChild: (Stack new
				 add: #Method;
				 yourself)
		of: node given: node1;
		updateNodeChild: (Stack new
				 add: #And;
				 yourself)
		of: node;
		updateNodeChild: (Stack new
				 add: #Block;
				 add: #Method;
				 yourself)
		of: node given: node2.
	node ifNotNil: [ self distanceFromSolutionOf: node ].
	^ node
]

{ #category : #accessing }
GPAssertConfiguration >> numberOfFailures [
	^ numberOfFailures
]

{ #category : #accessing }
GPAssertConfiguration >> numberOfFailures: number [
	self assert: (number isInteger and: [ number positive ]).
	numberOfFailures := number
]

{ #category : #hooks }
GPAssertConfiguration >> numberOfGenerations [

	^ 50
]

{ #category : #accessing }
GPAssertConfiguration >> options [
	self assert: options notEmpty.
	^ options
]

{ #category : #accessing }
GPAssertConfiguration >> options: collection [
	self assert: collection notEmpty.
	options := collection
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> pickBestConsideringParents: individual [
	| col |
	col := (random shuffleElementsOf: individual parents) sort: [ :i1 :i2 | i1 fitness < i2 fitness ].
	^ col first fitness < individual fitness 
		ifTrue: [ | indiv |
			indiv := col first deepCopy.
			indiv addParent: col first.
			indiv ]
		ifFalse: [ individual ]
	"^ individuals 
		select: [ :ind | ind fitness < individual fitness ]
		ifFound: [ :p | | indiv | 
			indiv := p deepCopy.
			indiv addParent: p.
			indiv ]
		ifNone: [ | col |
			col := individuals select: [ :ind | ind fitness = individual fitness ].
			col ifEmpty: [ individual ] ifNotEmpty: [ random randomlySelect: col ] ]"
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> pickBestIndividual: individual1 and: individual2 [
	| newInd |
	individual1 fitness < individual2 fitness
		ifTrue: [ newInd := individual1 deepCopy.
			newInd addParent: individual1 ]
		ifFalse: [ newInd := individual2 deepCopy.
			newInd addParent: newInd ].
	^ newInd 
]

{ #category : #accessing }
GPAssertConfiguration >> populationSize [

	^ 500
]

{ #category : #accessing }
GPAssertConfiguration >> randomIterations: number [

	self assert: (number isInteger and: [ number > 0 ]).
	randomIterations := number
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> randomSubTree: tree given: symbol [

	| array |
	array := (Array with: symbol)
	         , (grammar ruleOptionOf: symbol) nodeOptions.
	^ random randomlySelect:
		  (tree withAllChildren select: [ :node | array includes: node id ])
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> replaceByIdAny: children1 of: individual by: children2 given: individual2 [
	| ids childIds replaced |
	replaced := false.
	ids := children1 collect: #id.
	childIds := children2 collect: #id.
	"nodeOptions := self getGrammarNodeOptions." 
	assocs := ids asSet asOrderedCollection 
		collect: [ :nodeId | | inds |
			inds := individual indexesOf: nodeId on: childIds.
			"inds addAll: (self getNodeIdOptions: nodeOptions given: nodeId and: childIds)."
			nodeId -> inds ]
		thenReject: [ :assoc | 
			assoc value isEmpty or: [ assoc key = #Variable ] ].
	assocs ifNotEmpty: [ | assoc node r |
		individual addParent: individual2.
		assoc := random randomlySelect: assocs.
		node := children1 at: (random randomlySelect: (individual indexesOf: assoc key on: ids)).
		r := (children2 at: (random randomlySelect: assoc value)) deepCopy.
		node replaceBy: r.
		replaced := true
	].
	^ replaced
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> replaceByNode: children1 of: individual by: children2 given: individual2 [

	| selectedChildren1 selectedChildren2 |
	selectedChildren1 := children1 select: [ :child | 
		                     child isComplexNode and: [ 
			                     child nodeChildren size > 1 and: [ 
				                     child nodeChildren first id = #Variable ] ] ].
	selectedChildren2 := children2 select: [ :child | 
		                     child isComplexNode and: [ 
			                     child nodeChildren size > 1 and: [ 
				                     child nodeChildren first id = #Variable ] ] ].
	^ (selectedChildren1 notEmpty and: [ selectedChildren2 notEmpty ])
		  ifFalse: [ nil ]
		  ifTrue: [ 
			  | node |
			  node := random randomlySelect: selectedChildren1.
			  node addParent: individual2.
			  node replaceBy:
				  (random randomlySelect: selectedChildren2) deepCopy.
			  individual ]
]

{ #category : #accessing }
GPAssertConfiguration >> targetClass [
	^ targetClass
]

{ #category : #accessing }
GPAssertConfiguration >> targetClass: aClass [
	targetClass := aClass
]

{ #category : #accessing }
GPAssertConfiguration >> targetSelector [
	^ targetSelector
]

{ #category : #accessing }
GPAssertConfiguration >> targetSelector: aSelector [
	targetSelector := aSelector 
]

{ #category : #accessing }
GPAssertConfiguration >> targetSelectors [
	self assert: targetClass notNil.
	^ targetSelectors
]

{ #category : #accessing }
GPAssertConfiguration >> targetSelectors: collection [
	targetSelectors := collection 
]

{ #category : #accessing }
GPAssertConfiguration >> testClasses: classes [
	self assert: (classes notEmpty and: [ classes allSatisfy: #isClass ]).
	testClasses := classes 
]

{ #category : #actions }
GPAssertConfiguration >> uninstall [
	self assert: targetClass notNil.
	self assert: targetSelector notNil.
	self assert: originalMethod notNil.
	targetClass methodDict at: targetSelector put: originalMethod 
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> updateGrammar [
	grammar ifNil: [ self buildGrammar ].
	self addTargetVariable.
	^ grammar
	
]
