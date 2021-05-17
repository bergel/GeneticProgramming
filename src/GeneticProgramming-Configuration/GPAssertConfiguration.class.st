Class {
	#name : #GPAssertConfiguration,
	#superclass : #GPConfiguration,
	#instVars : [
		'targetClass',
		'testClass',
		'targetSelector',
		'originalMethod',
		'options',
		'grammar',
		'targetSelectors',
		'builder',
		'index',
		'contextBlocks',
		'numberOfFailures'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #adding }
GPAssertConfiguration >> addOptionArgs: symbols [
	grammar ifNil: [ self buildGrammar ].
	grammar addOptions: symbols forCollectionOptionsBeginWith: #Args
]

{ #category : #adding }
GPAssertConfiguration >> addOptionClasses: classNames [
	| clsNames |
	classNames ifEmpty: [ ^ self ].
	grammar ifNil: [ self buildGrammar ].
	clsNames := classNames intersection: classNames.
	grammar addOptions: clsNames forLeafRule: #Class
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

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> buildGrammar [
	self assert: targetClass notNil.
	grammar := builder buildAssertionGrammar: targetClass of: self targetSelectors.
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
		ifEmpty: [ [ self countErrorsGiven: [ targetClass new ] ] on: Exception do: [ 30 ] ] 
		ifNotEmpty: [ [(contextBlocks collect: [ :block | 
				self countErrorsGiven: block ]) min] on: Exception do: [ 30 ] ]
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> countErrorsGiven: block [
	| rm res |
	self assert: block isBlock.
	rm := GPRandom instance.
	res := (1 to: 30) inject: 0 into: [ :sum :num | | args |
		args := (1 to: targetSelector numArgs) collect: [ :a | 
		        rm randomlySelect: self options ].
		sum + ([ block value perform: targetSelector withArguments: args.
			0 ]
			on: Exception
			do: [ :e | "Transcript show: individual print, String cr, args asString, String cr, e class name, '->', e messageText, String cr."
				e class == AssertionFailure 
				ifTrue: [ 0 ] 
				ifFalse: [ 1 "e class == MessageNotUnderstood 
					ifTrue: [ 0 ] 
					ifFalse: [ 1 ]" ] ] ) ] .
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
			"children1 at: (random randomlySelect: (individual indexesOf: nodeId on: ids)) put: (children2 at: (random randomlySelect: indexes)) deepCopy."
			(children1 at: (random randomlySelect: (individual indexesOf: nodeId on: ids))) replaceBy: (children2 at: (random randomlySelect: indexes)) deepCopy.
			^ individual ] 
		"ifNone: [
			children1 
				detect: [ :child | | ind |
					ind := self crossover: individual between: child children and: children2.
					ind notNil ]
				ifFound: [ ^ individual ] ]".
	^ nil
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> crossover: individual1 with: individual2 [
	| copy i |
	copy := individual1 deepCopy.
	i := (((copy children at: 3) children collect: #id) includes: #Method) 
		ifTrue: [ 3 ] 
		ifFalse: [ 4 ].
	^ self crossover: copy between: (copy withAllChildren allButFirst: 4) "(copy children at: 3) children" and: (individual2 withAllChildren allButFirst: i "4")
]

{ #category : #operations }
GPAssertConfiguration >> distanceFromSolutionOf: individual [
	| t e uninstalled |
	self assert: targetClass notNil.
	self assert: testClass notNil.
	uninstalled := false.
	[ self injectIntoMethod: individual ] on: Exception do: [ 
		uninstalled := true.
		self uninstall.
	].
	e := self countErrors.
	t := testClass buildSuite run.
	individual fitness: (GPMultiObjectiveFitness new 
		addObjective: 'nRandomErrors' -> (uninstalled ifTrue: [ 30 ] ifFalse: [ e ]);
		addObjective: 'nTestErrors' -> (uninstalled ifTrue: [ t runCount ] ifFalse: [ (t failureCount + t errorCount)]);
		addFunctions: (Dictionary new 
			add: '=' -> [ :f1 :f2 | (f1 objectiveAt: 'nTestErrors') = (f2 objectiveAt: 'nTestErrors') and: [ (f1 objectiveAt: 'nRandomErrors') = (f2 objectiveAt: 'nRandomErrors') ] ];
			add: '<' -> [ :f1 :f2 | (f1 objectiveAt: 'nTestErrors') < (f2 objectiveAt: 'nTestErrors') 
					ifFalse: [ (f1 objectiveAt: 'nTestErrors') = (f2 objectiveAt: 'nTestErrors') 
						ifTrue: [ (f1 objectiveAt: 'nRandomErrors') < (f1 objectiveAt: 'nRandomErrors') ]
						ifFalse: [ false ] ]
					ifTrue: [ true ] ];
			add: '>' -> [ :f1 :f2 | (f1 objectiveAt: 'nTestErrors') > (f1 objectiveAt: 'nTestErrors') 
					ifFalse: [ (f1 objectiveAt: 'nTestErrors') = (f2 objectiveAt: 'nTestErrors') 
						ifTrue: [ (f1 objectiveAt: 'nRandomErrors') > (f2 objectiveAt: 'nRandomErrors') ]
						ifFalse: [ false ] ]
					ifTrue: [ true ] ];
			add: 'shouldTerminate' -> [ :f1 | (f1 objectiveAt: 'nTestErrors') == 0 and: [ (f1 objectiveAt: 'nRandomErrors') == 0 ] ];
			add: 'asNumber' -> [:f1 | ((f1 objectiveAt: 'nTestErrors') * 0.7) + ((f1 objectiveAt: 'nRandomErrors') * 0.3) ];
			yourself )).
	self uninstall.
	^ individual fitness
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
	numberOfFailures := 0
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> injectIntoMethod: individual [
	| aBehavior rbMethodNode |
	self assert: targetSelector notNil.
	self assert: targetClass notNil.
	aBehavior := targetClass instanceSide.
	originalMethod := "targetClass methodNamed: targetSelector." aBehavior compiledMethodAt: targetSelector.
	rbMethodNode := RBParser
		parseMethod: originalMethod sourceCode.
	rbMethodNode body addNodeFirst: individual ast.
	"copy := originalMethod copy.
	copy ast body addNodeFirst: individual ast."
	targetClass compile: rbMethodNode printString notifying: nil.
	"aBehavior methodDict at: targetSelector put: copy." 
]

{ #category : #operations }
GPAssertConfiguration >> mutate: individual [
	self mutate: individual with: self newTerminal.
]

{ #category : #operations }
GPAssertConfiguration >> mutate: individual with: source [
	| children indivIds sceChildren sourceIds nodeToMutate node |
	children := GPRandom instance shuffleElementsOf: (individual withAllChildren allButFirst: 4).
	indivIds := children collect: #id.
	sceChildren := source withAllChildren allButFirst: 4.
	sourceIds := sceChildren collect: #id.
	(indivIds includesAny: sourceIds) ifFalse: [ ^ self ].
	nodeToMutate := children at: (indivIds indexOfAnyOf: sourceIds).
	node := sceChildren at: (sourceIds indexOf: nodeToMutate id).
	nodeToMutate evaluationBlock: node evaluationBlock.
	nodeToMutate printBlock: node printBlock.
	"nodeToMutate type: node type."
	nodeToMutate children: node children.
	nodeToMutate nodeValue: node nodeValue
]

{ #category : #hooks }
GPAssertConfiguration >> newFunction [ 
	| node found i |
	found := false.
	i := 0.
	grammar := self updateGrammar.
	[ found or: [ i > 100 ] ] whileFalse: [ 
		depthModified ifFalse: [ depth := GPRandom instance randomNumber: 5 ].
		self assert: depth notNil.
		grammar 
			methodName: (GPRandom instance randomlySelect: #(#full #grow));
			configuration: self.
		node := grammar expandTree: #Assertion.
		found := node isNotNil.
		i := i + 1. ].
	"self assert: node notNil."
	node ifNotNil: [
		node evaluationBlock: [ :n :ctx | n ast ];
			printBlock: [ :n :ctx | n ast formattedCode ] ]
		ifNil: [ ^ nil ].
	^ node
]

{ #category : #hooks }
GPAssertConfiguration >> newTerminal [
	^ self newFunction 
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
	^ 60
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

{ #category : #accessing }
GPAssertConfiguration >> populationSize [ 
	^ 25
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
GPAssertConfiguration >> testClass [
	^ testClass
]

{ #category : #accessing }
GPAssertConfiguration >> testClass: aClass [
	testClass := aClass 
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
