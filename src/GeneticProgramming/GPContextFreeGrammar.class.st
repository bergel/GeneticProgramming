Class {
	#name : #GPContextFreeGrammar,
	#superclass : #Object,
	#instVars : [
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
GPContextFreeGrammar >> addOptions: collection forCollectionOptionsBeginWith: symbol [
	options associations 
		select: [ :assoc |
		(assoc key beginsWith: symbol) and: [ (assoc key copyFrom: symbol size + 1 to: assoc key size) isAllDigits ] ]
		thenDo: [ :assoc | assoc value addValueOptions: collection at: 1 ]
]

{ #category : #adding }
GPContextFreeGrammar >> addOptions: collection forLeafRule: symbol [
	| opt |
	opt := self ruleOptionOf: symbol.
	self assert: opt notNil.
	opt addToValueOptions: collection at: 1
]

{ #category : #adding }
GPContextFreeGrammar >> addOptions: collection forSelectorRule: symbol [
	self addOrReplaceSelectorRule: symbol withValues: collection
]

{ #category : #adding }
GPContextFreeGrammar >> addOrReplaceSelectorRule: symbol withValues: collection [
	| opt |
	opt := self ruleOptionOf: symbol.
	opt
		ifNil: [ self addSelectorRule: symbol withValues: collection ]
		ifNotNil: [ opt addValueOptions: collection at: 1 ]
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

{ #category : #adding }
GPContextFreeGrammar >> collectValueForRule: symbol at: index considering: integer [
	^ options at: symbol 	
		ifPresent: [ :ruleOption |
			"self shuffleOrSortOptions: (ruleOption getValueOptionsAt: index) of: symbol regarding: integer"
			self shuffle: (ruleOption getValueOptionsAt: index) ]
		ifAbsent: [ nil ]
]

{ #category : #accessing }
GPContextFreeGrammar >> configuration: aConfiguration [
	configuration := aConfiguration 
]

{ #category : #adding }
GPContextFreeGrammar >> createOrReplaceLeafRule: symbol ofClass: aClass withValues: collection [
	| opt |
	opt := self ruleOptionOf: symbol.
	opt 
		ifNil: [ self addLeafRule: symbol ofClass: aClass withValues: collection deepCopy ]
		ifNotNil: [ opt replaceValueOptions: collection deepCopy at: 1 ]
	
]

{ #category : #accessing }
GPContextFreeGrammar >> depth [ 
	^ depth
]

{ #category : #accessing }
GPContextFreeGrammar >> depth: integer [
	depth := integer
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> evaluationBlockOfNode: collection [
	^ [ :n :ctx | 
			[:nodeDepth :booleans | | children child | 
				children := OrderedCollection new.
				collection 
					detect: [ :id | 
						child := ctx expandTree: id from: nodeDepth + 1 with: booleans.
						children add: child.
						child isNil ]
					ifFound: [ nil ]
					ifNone: [ 
						(n isNotNil and: [ctx methodDepthBlock valueWithPossibleArgs: (Array with: booleans)]) 
						ifTrue: [ n deepCopy depth: nodeDepth; children: children ] 
						ifFalse: [ nil ] ] ]
	 ]
]

{ #category : #controlling }
GPContextFreeGrammar >> expand [

	 ^ self expandTree: self selectKeyRuleOption
]

{ #category : #controlling }
GPContextFreeGrammar >> expandGiven: aConfiguration [
	configuration := aConfiguration.
	 ^ self expand
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandTree: symbol [
	| found i tree numbers |
	found := false.
	i := 1.
	numbers := Set new.
	[ found or: [ i > 20 ] ] whileFalse: [ | includes |
		includes := true.
		[ includes and: [ i <= 20 ] ] whileTrue: [ 
			depth := configuration 
				ifNil: [ self randomlySelectOption: (1 to: 20) ] 
				ifNotNil: [ configuration depth ].
			includes := numbers includes: depth.
			i := i + 1
		 ].
		tree := [ self expandTree: symbol withDepth: depth ]
			on: Exception do: [ nil ].
		tree ifNil: [ numbers add: depth ]
			ifNotNil: [ found := true ] ].
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

	options := Dictionary new.
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

{ #category : #selecting }
GPContextFreeGrammar >> randomlySelectOption: collection [

	^ GPRandom instance randomlySelect: collection
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> ruleOptionOf: symbol [
	^ options at: symbol ifAbsent: [ nil ]
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRuleOption [

	 ^ configuration 
			ifNil: [ self randomlySelectOption: options keys ] 
			ifNotNil: [ configuration selectRuleKey: options keys ]
]

{ #category : #adding }
GPContextFreeGrammar >> selectValueForRule: symbol at: index [
	^ options at: symbol 	
		ifPresent: [ :ruleOption | | valueOptions |
			valueOptions := ruleOption getValueOptionsAt: index.
			configuration 
				ifNil: [ self randomlySelectOption: valueOptions ]
				ifNotNil: [ configuration selectValue: valueOptions forRule: symbol ] ]
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
	^ GPRandom instance shuffleElementsOf: collection
	"^ configuration 
		ifNil: [ GPRandom instance shuffleElementsOf: collection ] 
		ifNotNil: [ configuration shuffle: collection forRule: symbol ]"
]
