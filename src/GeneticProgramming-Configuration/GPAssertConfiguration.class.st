Class {
	#name : #GPAssertConfiguration,
	#superclass : #GPConfiguration,
	#instVars : [
		'targetClass',
		'testClass',
		'targetSelectors',
		'grammars',
		'targetSelector',
		'originalMethod',
		'options'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #'as yet unclassified' }
GPAssertConfiguration >> buildGrammar: selector [
	self assert: targetClass notNil.
	^ (GPAssertionGrammarBuilder buildAssertionGrammar: targetClass of: selector)
		configuration: self
	
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
	grammars := Dictionary new.
	targetSelectors := OrderedCollection new.
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
	| node found i grammar |
	self assert: targetSelectors notEmpty.
	found := false.
	i := 0.
	targetSelector ifNil: [ targetSelector := random randomlySelect: targetSelectors ].
	grammars at: targetSelector ifAbsentPut: [ self buildGrammar: targetSelector ].
	grammar := grammars at: targetSelector.
	[ found or: [ i > 10 ] ] whileFalse: [ 
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
	options ifEmpty: [ 
		^ { nil . 42 . 'hello' . 0 . 1.2 . #(). -4. 0. '' } ].
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
GPAssertConfiguration >> targetClass: aClass [
	targetClass := aClass
]

{ #category : #accessing }
GPAssertConfiguration >> targetSelector: aSelector [
	targetSelector := aSelector 
]

{ #category : #accessing }
GPAssertConfiguration >> targetSelectors: selectors [
	targetSelectors := selectors 
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
