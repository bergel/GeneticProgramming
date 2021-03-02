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
		'builder'
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
	grammar ifNil: [ self buildGrammar ].
	grammar addOptions: classNames forLeafRule: #Class
]

{ #category : #adding }
GPAssertConfiguration >> addOptionSelectors: selectors [
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
	grammar createOrReplaceLeafRule: #Variable ofClass: RBVariableNode withValues: vals
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
	self assert: targetSelectors notEmpty.
	builder := GPAssertionGrammarBuilder new.
	grammar := builder buildAssertionGrammar: targetClass of: targetSelectors.
	grammar configuration: self
	
]

{ #category : #accessing }
GPAssertConfiguration >> countErrors [

	^ ((1 to: 20) collect: [ :n | | obj args |
		obj := targetClass new.
		args := (1 to: targetSelector numArgs) collect: [ :a | 
		        random randomlySelect: self options ].
	 	[ obj perform: targetSelector withArguments: args.
			0 ]
			on: Error
			do: [ :ex | 
			ex class == AssertionFailure
				     ifTrue: [ 0 ]
				     ifFalse: [ 1 ] ] ]) min
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
	[ self injectIntoMethod: individual ] on: Error do: [ 
		self uninstall.
	].
	f := self countErrors.
	t := testClass buildSuite run.
	individual fitness: f + t runCount + t failureCount + t errorCount - t passedCount.
	self uninstall.
	^ individual fitness
]

{ #category : #initialization }
GPAssertConfiguration >> initialize [ 
	super initialize.
	options := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> injectIntoMethod: individual [
	| "copy" aBehavior rbMethodNode |
	self assert: targetSelector notNil.
	self assert: targetClass notNil.
	aBehavior := targetClass instanceSide.
	originalMethod := "targetClass methodNamed: targetSelector." aBehavior methodDict at: targetSelector.
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
	children := GPRandom instance shuffleElementsOf: (individual withAllChildren allButFirst "select: #isLeaf").
	source := self newTerminal.
	indivIds := children collect: #id.
	sceChildren := source withAllChildren "select: #isLeaf".
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
		depth ifNil: [ depth := GPRandom instance randomNumber: 10 ].
		grammar 
			methodName: (GPRandom instance randomlySelect: #(#full #grow));
			configuration: self.
		node := grammar expandTree: #Assertion.
		found := node isNotNil.
		i := i + 1. ].
	self assert: node notNil.
	node evaluationBlock: [ :n :ctx | n ast ];
		printBlock: [ :n :ctx | n ast formattedCode ].
	^ node
]

{ #category : #hooks }
GPAssertConfiguration >> newTerminal [
	^ self newFunction 
]

{ #category : #hooks }
GPAssertConfiguration >> numberOfGenerations [ 
	^ 20
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
	^ 30
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
		targetSelectors := targetClass methods 
			collect: #selector 
			thenSelect: [ :s | s numArgs > 0 ] ].
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