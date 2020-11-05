Class {
	#name : #GPContextFreeGrammar,
	#superclass : #Object,
	#instVars : [
		'rules',
		'options',
		'nodeNumber',
		'configuration'
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

	 self
		 addRule: symbol
		 withSequence: (Array with: anotherSymbol)
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: symbol withCollectionOptions: collection [

	self
		addNodeIfNecessary: symbol
		ofClass: GPCollectionNode
		andType: nil.
	self
		addOptions: (collection collect: [ :s | 
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
	| dict opts weights |
	dict := Dictionary new.
		opts := self optionsOf: symbol.
		weights := configuration optionWeightsOf: symbol.
		(opts size == weights size) ifTrue: [ 
				dict :=  (opts
					   with: weights
					   collect: [ :i :w | i -> w ]) asDictionary ].
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
			(configuration isNotNil and: [ configuration depth isNotNil ])
				ifTrue: [ 
					^ node
						          expandGiven: self
						          depth: configuration depth
						          and: OrderedCollection new ]
				ifFalse: [ ^ node expandGiven: self ].
			 ]
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
GPContextFreeGrammar >> optionsOf: symbol [

	 ^ options at: symbol
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> randomOptions: symbol [

	^ self shuffle: (self optionsOf: symbol)
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> randomlySelectOption: symbol [

	| dict|
	configuration ifNil: [ ^ GPRandom instance randomlySelect: (self optionsOf: symbol) ].
	dict := self dictionaryOfOptionsWithWeights: symbol.
	^ dict ifEmpty: [ GPRandom instance randomlySelectGivenProbabilities: dict ] ifNotEmpty: [  
		
				  
	GPRandom instance randomlySelect: (self optionsOf: symbol) ]
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
					   collect: [ :i :w | i -> w ]) asDictionary ]
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
