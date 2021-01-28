Class {
	#name : #GPContextFreeGrammar,
	#superclass : #Object,
	#instVars : [
		'nodeNumber',
		'configuration',
		'options',
		'depth',
		'methodName'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #adding }
GPContextFreeGrammar >> addLeafRule: symbol ofClass: aClass withValues: collection [
	| optionRule index |
	self addRuleOptionIfNecessary: symbol.
	optionRule := options at: symbol.
	index := optionRule nodes size.
	optionRule 
		addNode: (GPLeafNode new id: symbol; type: aClass; 
			evaluationBlock: [:n :ctx | 
				[:nodeDepth :booleans | 
					booleans add: nodeDepth == depth.
					n deepCopy
						nodeValue: (ctx selectValueForRule: symbol at: index + 1); 
						depth: nodeDepth ]];
			printBlock: [:n :ctx | n nodeValue asString ]) 
		withValueOptions: collection asOrderedCollection 
]

{ #category : #adding }
GPContextFreeGrammar >> addLeafRule: symbol withValues: collection [

	self addLeafRule: symbol ofClass: nil withValues: collection
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol ofClass: aClass withSequence: collection [
	| optionRule |
	self addRuleOptionIfNecessary: symbol.
	optionRule := options at: symbol.
	optionRule 
		addNode: (GPNode new id: symbol; type: aClass; 
			children: collection asOrderedCollection;
			evaluationBlock: (self evaluationBlockOfNode: collection);
			printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString ])
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol redirectingTo: anotherSymbol [
	self addRuleOptionIfNecessary: symbol.
	(options at: symbol) addNodeOption: anotherSymbol
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol withCollectionOptions: collection ofSize: anInteger [
	"collection is an array with the rule names of the grammar"
	| optionRule index |
	self addRuleOptionIfNecessary: symbol.
	optionRule := options at: symbol.
	index := optionRule nodes size.
	optionRule 
		addNode: (GPCollectionNode new id: symbol;
			evaluationBlock: [:n :ctx | 
				[:nodeDepth :booleans | | allOptions |
					allOptions := self collectValueForRule: symbol at: index + 1 considering: nodeDepth.
					allOptions := (allOptions collect: [ :opt | ctx expandTree: opt from: nodeDepth + 1 with: booleans ] 
						thenReject: [ :t | t isNil ]) collect: #id.
					allOptions 
						ifEmpty: [ nil ] 
						ifNotEmpty: [ allOptions size < anInteger 
							ifTrue: [ allOptions := (self shuffle: (self fillArrayOfSize: allOptions size to: anInteger )) collect: [:i | allOptions at: i ] ].
					n deepCopy 
						depth: nodeDepth; 
						children: ((1 to: anInteger) collect: [ :i | ctx expandTree: (allOptions at: i) from: nodeDepth + 1 with: booleans ]) ] ] ];
			printBlock: [:n :ctx | (n withAllChildren collect: #id) asArray asString ]) 
		withValueOptions: collection asOrderedCollection.
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol withOptions: collection [
	collection do: [ :e | self addRule: symbol redirectingTo: e ]
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol withSequence: sequence [

	self addRule: symbol ofClass: nil withSequence: sequence
]

{ #category : #adding }
GPContextFreeGrammar >> addRuleOptionIfNecessary: symbol [
	options at: symbol 
		ifAbsentPut: [ GPRuleOption new ruleName: symbol ].
]

{ #category : #adding }
GPContextFreeGrammar >> addSelectorRule: symbol withValues: collection [
	| optionRule index |
	self addRuleOptionIfNecessary: symbol.
	optionRule := options at: symbol.
	index := optionRule nodes size.
	optionRule 
		addNode: (GPSelectorNode new id: symbol; 
			evaluationBlock: [:n :ctx | 
				[ :nodeDepth :booleans | 
					n deepCopy
						depth: nodeDepth;
						nodeValue: (ctx selectValueForRule: symbol at: index + 1)]];
			printBlock: [:n :ctx | n nodeValue ]) 
		withValueOptions: collection asOrderedCollection 
]

{ #category : #accessing }
GPContextFreeGrammar >> allOptionsOf: symbol [
	| opts nodeOpts dict |
	opts := self optionsOf: symbol.
	nodeOpts := self nodeOptionsOf: symbol.
	dict := Dictionary new.
	opts ifNotEmpty: [	dict at: 'options' put: opts ].
	nodeOpts ifNotEmpty: [ dict at: 'nodeOptions' put: nodeOpts ].
	^ dict
]

{ #category : #adding }
GPContextFreeGrammar >> collectValueForRule: symbol at: index considering: integer [
	^ options at: symbol 	
		ifPresent: [ :ruleOption |
			self shuffleOrSortOptions: (ruleOption getValueOptionsAt: index) of: symbol regarding: integer ]
		ifAbsent: [ nil ]
]

{ #category : #accessing }
GPContextFreeGrammar >> configuration: aConfiguration [
	configuration := aConfiguration 
]

{ #category : #accessing }
GPContextFreeGrammar >> depth [ 
	^ depth
]

{ #category : #accessing }
GPContextFreeGrammar >> depth: integer [
	depth := integer
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> dictionaryOfOptionsWithWeights: symbol [

	| dict indexOpts weights |
	dict := Dictionary new.
	indexOpts := 1 to: "(self optionsOf: symbol)" ((self allOptionsOf: symbol) flatCollect: #value) size.
	weights := configuration optionWeightsOf: symbol.
	indexOpts size == weights size ifTrue: [ 
		dict := (indexOpts with: weights collect: [ :i :w | i -> w ])
			        asOrderedDictionary ].
	^ dict
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> evaluationBlockOfNode: collection [
	^ [ :n :ctx | 
			[:nodeDepth :booleans | | children child | 
				children := OrderedCollection new.
				collection 
					detect: [ :id | 
						child := self expandTree: id from: nodeDepth + 1 with: booleans.
						children add: child.
						child isNil ]
					ifFound: [ nil ]
					ifNone: [ 
						(n isNotNil and: [self methodDepthBlock valueWithPossibleArgs: (Array with: booleans)]) 
						ifTrue: [ n deepCopy depth: nodeDepth; children: children ] 
						ifFalse: [ nil ] ] ]
	 ]
]

{ #category : #controlling }
GPContextFreeGrammar >> expand [

	 ^ self expandTree: self selectKeyRuleOption
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandTree: symbol [
	| found i tree numbers |
	found := false.
	i := 1.
	numbers := Set new.
	[ found or: [ i > 20 ] ] whileFalse: [ | includes |
		includes := true.
		[ includes ] whileTrue: [ 
			depth := configuration 
				ifNil: [ self randomlySelectOption: (1 to: 20) ] 
				ifNotNil: [ configuration depth ].
			includes := numbers includes: depth
		 ].
		tree := [ self expandTree: symbol withDepth: depth ]
			on: Error do: [ nil ].
		tree ifNil: [ numbers add: depth ]
			ifNotNil: [ found := true ].
		i := i + 1 ].
	^ tree
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandTree: symbol from: integer with: booleans [
	| allOptions opts |
	integer > depth ifTrue: [ ^ nil ].
	allOptions := self shuffleOrSortOptions: (options at: symbol) allOptions of: symbol regarding: integer.
	allOptions ifEmpty: [ ^ nil ].
	opts := OrderedCollection new.
	^ allOptions 
		detect: [ :assoc | | bool size tree prevSize |
			prevSize := booleans size.
			tree := assoc key = 'node'
				ifTrue: [ | node |
					node := assoc value key.
					(node evaluateUsing: self) valueWithPossibleArgs: (Array with: integer with: booleans) ]
				ifFalse: [ self expandTree: assoc value from: integer + 1 with: booleans ].
			bool := tree isNotNil and: [self methodDepthBlock valueWithPossibleArgs: (Array with: booleans)].
			size := booleans size.
			tree ifNotNil: [ opts add: tree ].
			(methodName = #full and: [(size - prevSize) > 0]) ifTrue: [ 
				1 to: (size - prevSize) do: [:n | booleans pop ] ].
			bool ] 
		ifFound: [ :assoc | opts last ] 
		ifNone: [ opts ifEmpty: [ nil ] ifNotEmpty: [ booleans push: false.
				self randomlySelectOption: opts ] ]. 
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandTree: axiom given: aConfiguration [

	self configuration: aConfiguration.
	^ self expandTree: axiom
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandTree: symbol withDepth: integer [
	depth := integer.
	^ self expandTree: symbol from: 0 with: Stack new
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> fillArrayOfSize: size1 to: size2 [
	| aux |
	aux := 0.
	^ (1 to: size2) collect: [ :n | aux := n // size1.
		n == (aux * size1) ifTrue: [ size1 ] ifFalse: [ n - (aux * size1) ] ]
]

{ #category : #initialization }
GPContextFreeGrammar >> initialize [

	"rules := Dictionary new.
	options := Dictionary new."
	"nodeOptions := Dictionary new."
	options := Dictionary new.
	nodeNumber := 0.
	methodName := #grow
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> methodDepthBlock [
	| block |
	block := nil.
	methodName = #full 
		ifTrue: [ block := [ :bools | bools inject: true into: [ :b :e | e and: [ b ] ] ] ].
	methodName = #grow ifTrue: [ block := [ :bools | bools inject: false into: [ :b :e | e or: [ b ] ] ] ].
	^ block
]

{ #category : #accessing }
GPContextFreeGrammar >> methodName: string [
	(#('full' 'grow') includes: string) ifTrue: [ 
		methodName := string	
	]
	
]

{ #category : #accessing }
GPContextFreeGrammar >> nodeNumber [
	nodeNumber := nodeNumber + 1.
	^ nodeNumber
]

{ #category : #accessing }
GPContextFreeGrammar >> nodeOptionsOf: symbol [
	"to remove"
	| nodeOptions |
	 ^ nodeOptions at: symbol ifAbsent: [ #() ]
]

{ #category : #accessing }
GPContextFreeGrammar >> optionsOf: symbol [

	 ^ options at: symbol ifAbsent: [ #() ]
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> randomOptions: symbol [

	^ self shuffle: (
		(self shuffle: (self allOptionsOf: symbol) associations) flatCollect: #value) "(self optionsOf: symbol)"
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> randomOptionsOf: symbol [

	^ (configuration isNil or: [ (self dictionaryOfOptionsWithWeights: symbol) isEmpty ])
		ifTrue: [ self randomOptions: symbol ] 
		ifFalse: [ | col opts set result | 
			opts := (self allOptionsOf: symbol) associations flatCollect: #value.
			col := GPRandom instance shuffledCollectionOf: (self dictionaryOfOptionsWithWeights: symbol).
			set := Set new.
			result := OrderedCollection new.
			col do: [ :i | (set includes: i) 
				ifFalse: [ set add: i.
					result add: (opts at: i) ] ].
			result
		]
]

{ #category : #selecting }
GPContextFreeGrammar >> randomlySelectOption: collection [

	^ GPRandom instance randomlySelect: collection
]

{ #category : #selecting }
GPContextFreeGrammar >> randomlySelectOption: assocs regarding: integer [

	integer == depth ifTrue: [ | newCol |
		newCol := assocs select: [ :ass | ass key = 'node' ].
		^ newCol 
			ifEmpty: [ nil ] 
			ifNotEmpty: [ GPRandom instance randomlySelect: newCol ] ].
	configuration ifNil: [ 
		^ GPRandom instance randomlySelect: assocs ].
	self halt.
	^ assocs
		  ifEmpty: [ 
		  GPRandom instance randomlySelectOfDictionary: (self allOptionsOf: nil"symbol") "randomlySelect: (self optionsOf: symbol)" ]
		  ifNotEmpty: [ 
		  "(self optionsOf: symbol)" (self allOptionsOf: nil "symbol") associations first value at: (GPRandom instance randomlySelectGivenProbabilities: assocs) ]
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> ruleOptionOf: symbol [
	^ options at: symbol ifAbsent: [ nil ]
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRuleOption [

	 ^ configuration 
			ifNil: [ self randomlySelectOption: options keys ] 
			ifNotNil: [ self halt ]
]

{ #category : #adding }
GPContextFreeGrammar >> selectValueForRule: symbol at: index [
	^ options at: symbol 	
		ifPresent: [ :ruleOption | | valueOptions |
			valueOptions := ruleOption getValueOptionsAt: index.
			configuration 
				ifNil: [ self randomlySelectOption: valueOptions ]
				ifNotNil: [ self halt. configuration select: valueOptions ] ]
		ifAbsent: [ nil ]
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> shuffle: collection [
	^ GPRandom instance shuffleElementsOf: collection 
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> shuffleOrSortOptions: collection of: symbol regarding: integer [
	integer == depth ifTrue: [
		^ GPRandom instance  shuffleElementsOf: (collection select: [ :ass | ass key = 'node' ]) ].
	^ configuration 
		ifNil: [ GPRandom instance shuffleElementsOf: collection ] 
		ifNotNil: [ self halt. configuration shuffle: collection forRule: symbol  ]
]
