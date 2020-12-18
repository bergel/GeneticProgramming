Class {
	#name : #GPContextFreeGrammar,
	#superclass : #Object,
	#instVars : [
		'rules',
		'nodeNumber',
		'configuration',
		'options',
		'nodeOptions'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #adding }
GPContextFreeGrammar >> addLeafRule: symbol ofClass: aClass withValues: collection [

	self
		addNodeIfNecessary: symbol
		ofClass: GPLeafNode
		andType: aClass.
	self addOptions: collection of: symbol
]

{ #category : #adding }
GPContextFreeGrammar >> addLeafRule: symbol withValues: collection [

	self addNodeIfNecessary: symbol ofClass: GPLeafNode andType: RBLiteralNode.
	self addOptions: collection of: symbol
]

{ #category : #adding }
GPContextFreeGrammar >> addMessageRule: symbol withValues: collection [

	self addNodeIfNecessary: symbol ofClass: GPMessageNode  andType: nil.
	self addOptions: collection of: symbol
]

{ #category : #adding }
GPContextFreeGrammar >> addNodeIfNecessary: symbol ofClass: aClass andType: anotherClass [
rules at: symbol ifAbsentPut: [ 
		self
			createNode: symbol
			ofClass: aClass
			type: anotherClass
			withSequence: #(  ) ].
]

{ #category : #adding }
GPContextFreeGrammar >> addNodeOptions: collection of: symbol [

	 nodeOptions 
		 at: symbol
		 ifPresent: [ :col | col addAll: collection ]
		 ifAbsentPut: [ 
			 OrderedCollection new
				 addAll: collection;
				 yourself ]
]

{ #category : #adding }
GPContextFreeGrammar >> addOptions: collection of: symbol [

	 options
		 at: symbol
		 ifPresent: [ :col | col addAll: collection ]
		 ifAbsentPut: [ 
			 OrderedCollection new
				 addAll: collection;
				 yourself ]
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol ofClass: aClass withSequence: collection [

	self addNodeIfNecessary: symbol ofClass: GPNode andType: aClass.
	self
		addOptions: (Array with: (self
					  createNode: symbol
					  ofClass: GPNode
					  type: aClass
					  withSequence: collection))
		of: symbol
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol redirectingTo: anotherSymbol [
	 self addNodeIfNecessary: symbol
			ofClass: GPNode
			andType: nil.
	 self addNodeOptions: (Array with: anotherSymbol) of: symbol
	 "nodeOptions
		 at: symbol
		 ifPresent: [ :col | col add: anotherSymbol ]
		 ifAbsentPut: [ 
			 OrderedCollection new
				 add: anotherSymbol;
				 yourself ]."
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol withCollectionOptions: collection [

	self
		addNodeIfNecessary: symbol
		ofClass: GPCollectionNode
		andType: nil.
	self
		addNodeOptions: (collection collect: [ :s | 
				 self
					 createNode: symbol
					 ofClass: GPCollectionNode
					 type: nil
					 withSequence: (Array with: s) ])
		of: symbol
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol withOptions: collection [
	collection do: [ :e | self addRule: symbol redirectingTo: e ]
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol withSequence: sequence [

	self addRule: symbol ofClass: nil withSequence: sequence
]

{ #category : #accessing }
GPContextFreeGrammar >> allButMessageRuleKeys [

	^ rules associations
		  reject: [ :assoc | assoc value isMessageNode ]
		  thenCollect: [ :assoc | assoc key ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> allComplexRulesKeysBut: symbols [

	^ rules associations
		  select: [ :assoc | 
			  (assoc value isComplexNode) and: [ 
				  (symbols includes: assoc key) not ] ]
		  thenCollect: [ :assoc | assoc key ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> allLeavesRuleKeysBut: symbols [

	^ rules associations
		  select: [ :assoc | 
			  (assoc value isLeafNode) and: [ 
				  (symbols includes: assoc key) not ] ]
		  thenCollect: [ :assoc | assoc key ]
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

{ #category : #accessing }
GPContextFreeGrammar >> configuration: aConfiguration [
	configuration := aConfiguration 
]

{ #category : #adding }
GPContextFreeGrammar >> createNode: symbol ofClass: classNode type: aClass withSequence: sequence [

	^ classNode new
		  id: symbol;
		  type: aClass;
		  children: sequence
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

{ #category : #controlling }
GPContextFreeGrammar >> expand [

	 ^ self expandFrom: self selectKeyRule
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandFrom: axiom [

	rules
		at: axiom
		ifPresent: [ :node | 
			configuration isNotNil
				ifTrue: [ 
					configuration depth ifNil: [ 
						| result |
						result := nil.
						[ result isNil ] whileTrue: [ 
							configuration depth: (GPRandom instance randomNumber: 30).
							result := node
								          expandGiven: self
								          depth: configuration depth
								          and: OrderedCollection new ].
						^ result ].
					^ node
						  expandGiven: self
						  depth: configuration depth
						  and: OrderedCollection new ]
				ifFalse: [ ^ node expandGiven: self ] ]
		ifAbsent: [ ^ nil ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandFrom: axiom given: aConfiguration [

	self configuration: aConfiguration.
	^ self expandFrom: axiom
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandGiven:  depth and: ruleKeys [

	|axiom |
	axiom := self selectKeyRuleGiven: depth and: ruleKeys.
	^ rules
		  at: axiom
		  ifPresent: [ :node | 
			  | resNode bools |
			  bools := OrderedCollection new.
			  resNode := node expandGiven: self depth: depth and: bools.
			  resNode
				  ifNil: [ 
					  ruleKeys add: axiom.
					  self expandGiven: depth and: ruleKeys ]
				  ifNotNil: [ resNode ] ]
		  ifAbsent: [ nil ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandGiven: aConfiguration depth: depth and: ruleKeys [

	self configuration: aConfiguration.
	^ self expandGiven: depth and: ruleKeys
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandUsing: aConfiguration [

	^ aConfiguration depth
		  ifNil: [ 
			  self
				  expandFrom: (self selectKeyRuleGiven: aConfiguration)
				  given: aConfiguration ]
		  ifNotNil: [ 
			  self
				  expandGiven: aConfiguration
				  depth: aConfiguration depth
				  and: OrderedCollection new ]
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> generateASTFrom: aNode [

	| visitor |
	visitor := GPReplacementVisitor
		           new
		           grammar: self.
	^ aNode generateAST: visitor
]

{ #category : #testing }
GPContextFreeGrammar >> hasRule: symbol [
	^ rules at: symbol ifPresent: [ true ] ifAbsent: [ false ]
]

{ #category : #initialization }
GPContextFreeGrammar >> initialize [

	rules := Dictionary new.
	options := Dictionary new.
	nodeOptions := Dictionary new.
	nodeNumber := 0
]

{ #category : #accessing }
GPContextFreeGrammar >> nodeNumber [
	nodeNumber := nodeNumber + 1.
	^ nodeNumber
]

{ #category : #accessing }
GPContextFreeGrammar >> nodeOf: symbol [
	^ rules at: symbol
]

{ #category : #accessing }
GPContextFreeGrammar >> nodeOptionsOf: symbol [

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
GPContextFreeGrammar >> randomlySelectOption: symbol [

	| dict |
	configuration ifNil: [ 
		^ GPRandom instance randomlySelectOfDictionary: (self allOptionsOf: symbol) "randomlySelect: (self optionsOf: symbol)" ].
	dict := self dictionaryOfOptionsWithWeights: symbol.
	^ dict
		  ifEmpty: [ 
		  GPRandom instance randomlySelectOfDictionary: (self allOptionsOf: symbol) "randomlySelect: (self optionsOf: symbol)" ]
		  ifNotEmpty: [ 
		  "(self optionsOf: symbol)" (self allOptionsOf: symbol) associations first value at: (GPRandom instance randomlySelectGivenProbabilities: dict) ]
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRule [

	 ^ GPRandom instance randomlySelect: self allButMessageRuleKeys
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRuleGiven: aConfiguration [

	^ (aConfiguration keysOfRuleWeights includesAll:
		   self allButMessageRuleKeys)
		  ifFalse: [ self selectKeyRule ]
		  ifTrue: [ 
			  GPRandom instance randomlySelectGivenProbabilities:
				  aConfiguration rulesWeights ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> selectKeyRuleGiven: depth and: ruleKeys [

	| newCollection |
	newCollection := self
		                 selectRulesKeysGiven: depth
		                 andAvoiding: ruleKeys.
	newCollection ifEmpty: [ 
		self error:
			'AST can not be expanded with depth of: ' , depth asString ].
	^ configuration rulesWeights
		  ifEmpty: [ GPRandom instance randomlySelect: newCollection ]
		  ifNotEmpty: [ 
			  GPRandom instance randomlySelectGivenProbabilities:
				  (newCollection
					   with: (configuration rulesWeightsOf: newCollection)
					   collect: [ :i :w | i -> w ]) asOrderedDictionary ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> selectRulesKeysGiven: depth andAvoiding: ruleKeys [

	 ^ (depth == 1
		    ifTrue: [ self allLeavesRuleKeysBut: ruleKeys ]
		    ifFalse: [ self allComplexRulesKeysBut: ruleKeys ])
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> shuffle: collection [
	^ GPRandom instance shuffleElementsOf: collection 
]
