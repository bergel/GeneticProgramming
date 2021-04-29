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
	self assert: (collection isCollection and: [ collection notEmpty ]).
	contextBlocks := collection
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> countErrors [
	self assert: targetClass notNil.
	self assert: targetSelector notNil.
	^ contextBlocks 
		ifEmpty: [ [ self countErrorsGiven: [ targetClass new ] ] on: Exception do: [ 0 ] ] 
		ifNotEmpty: [ [(contextBlocks collect: [ :block | 
				self countErrorsGiven: block ]) min] on: Exception do: [ 0 ] ]
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> countErrorsGiven: block [
	| rm |
	self assert: block isBlock.
	rm := GPRandom instance.
	^ (1 to: 30) inject: 0 into: [ :sum :num | | args |
		args := (1 to: targetSelector numArgs) collect: [ :a | 
		        rm randomlySelect: self options ].
		sum + ([ block value perform: targetSelector withArguments: args.
			0 ]
			on: Exception
			do: [ :e | e class == AssertionFailure 
				ifTrue: [ 0 ] 
				ifFalse: [ 1 ] ])
	]
]

{ #category : #operations }
GPAssertConfiguration >> createNewIndividual [	
	^ self newFunction
]

{ #category : #operations }
GPAssertConfiguration >> distanceFromSolutionOf: individual [
	| t f |
	self assert: targetClass notNil.
	self assert: testClass notNil.
	[ self injectIntoMethod: individual ] on: Exception do: [ 
		self uninstall.
	].
	f := self countErrors.
	t := testClass buildSuite run.
	individual fitness: f + ((t failureCount + t errorCount - numberOfFailures) * 3).
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
	| "copy" aBehavior rbMethodNode |
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
	| source children nodeToMutate indivIds sourceIds sceChildren |
	children := GPRandom instance shuffleElementsOf: (individual withAllChildren allButFirst: 3 "select: #isLeaf").
	source := self newTerminal.
	indivIds := children collect: #id.
	sceChildren := source withAllChildren allButFirst: 3 "select: #isLeaf".
	sourceIds := sceChildren collect: #id.
	(indivIds includesAny: sourceIds) ifFalse: [ ^ self ].
	nodeToMutate := children at: (indivIds indexOfAnyOf: sourceIds).
	source := sceChildren at: (sourceIds indexOf: nodeToMutate id).
	nodeToMutate evaluationBlock: source evaluationBlock.
	nodeToMutate printBlock: source printBlock.
	nodeToMutate type: source type.
	nodeToMutate children: source children.
	nodeToMutate nodeValue: source nodeValue
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
		ifNil: [ self halt ].
	^ node
]

{ #category : #hooks }
GPAssertConfiguration >> newTerminal [
	^ self newFunction 
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
GPAssertConfiguration >> targetSelector: aSelector [
	targetSelector := aSelector 
]

{ #category : #accessing }
GPAssertConfiguration >> targetSelectors [
	self assert: targetClass notNil.
	targetSelectors ifEmpty: [ 
		targetSelectors := targetClass selectors 
			select: [ :s | s numArgs > 0 ] ].
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
