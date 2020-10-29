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
	"self addRule: symbol redirectingTo: s ]"
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
		   reject: [ :assoc | 
			   assoc value isMemberOf: GPMessageNode ]
		   thenCollect: [ :assoc | assoc key ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> allComplexRulesKeysBut: symbols [

	 ^ rules associations
		   select: [ :assoc | 
			   (assoc value isMemberOf: GPNode) and: [ 
				   (symbols includes: assoc key) not ] ]
		   thenCollect: [ :assoc | assoc key ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> allLeavesRuleKeysBut: symbols [

	 ^ rules associations
		   select: [ :assoc | 
			   (assoc value isMemberOf: GPLeafNode) and: [ 
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
		  children: sequence "(sequence collect: [ :c | classNode new id: c ])"
]

{ #category : #controlling }
GPContextFreeGrammar >> expand [

	 ^ self expandFrom: self selectKeyRule
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandFrom: axiom [

	 ^ rules
		   at: axiom
		   ifPresent: [ :node | node expandGiven: self ]
		   ifAbsent: [ nil ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandFrom: axiom given: aConfiguration [

	self configuration: aConfiguration.
	^ self expandFrom: axiom
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandGiven: configuration depth: depth and: ruleKeys [

	 | axiom |
	 axiom := self
		          selectKeyRuleGiven: configuration
		          depth: depth
		          and: ruleKeys.
	 ^ rules
		   at: axiom
		   ifPresent: [ :node | 
			   | resNode bools |
			bools := OrderedCollection new.
			   resNode := node
				              expandGiven: configuration
				              grammar: self
				              depth: depth
				              and: bools.
			   resNode
				   ifNil: [ 
					   ruleKeys add: axiom.
					   self expandGiven: configuration depth: depth and: ruleKeys ]
				   ifNotNil: [ resNode ] ]
		   ifAbsent: [ nil ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandReplacingFrom: axiom [

	| visitor |
	visitor := GPReplacementVisitor new grammar: self.
	^ rules
		  at: axiom
		  ifPresent: [ :node | node expandReplacingGiven: visitor and: self ]
		  ifAbsent: [ nil ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandReplacingFrom: axiom given: configuration [

	| visitor |
	visitor := GPReplacementVisitor new grammar: self.
	^ rules
		  at: axiom
		  ifPresent: [ :node | 
			  configuration depth
				  ifNil: [ node expandReplacingGiven: visitor and: self ]
				  ifNotNil: [ 
					  | bools |
					  bools := OrderedCollection new.
					  node
						  expandReplacingGiven: visitor
						  grammar: self
						  depth: configuration depth
						  and: bools ] ]
		  ifAbsent: [ nil ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandReplacingGiven: configuration depth: depth and: ruleKeys [

	| axiom |
	axiom := self
		         selectKeyRuleGiven: configuration
		         depth: depth
		         and: ruleKeys.
	^ rules
		  at: axiom
		  ifPresent: [ :node | 
			  | resNode  |
			  resNode := self expandReplacingFrom: axiom given: configuration.
			  resNode
				  ifNil: [ 
					  ruleKeys add: axiom.
					  self expandGiven: configuration depth: depth and: ruleKeys ]
				  ifNotNil: [ resNode ] ]
		  ifAbsent: [ nil ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandReplacingUsing: configuration [

	^ configuration depth
		  ifNil: [ 
			  self
				  expandReplacingFrom: (self selectKeyRuleGiven: configuration)
				  given: configuration ]
		  ifNotNil: [ 
		  self
			  expandReplacingGiven: configuration
			depth: configuration depth
			  and: OrderedCollection new ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> expandUsing: configuration [

	 ^ configuration depth
		   ifNil: [ 
			   self
				   expandFrom: (self selectKeyRuleGiven: configuration)
				   given: configuration ]
		   ifNotNil: [ 
			   self
				   expandGiven: configuration
				   depth: configuration depth
				   and: OrderedCollection new ]
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

	^ GPRandom instance shuffleElementsOf: (self optionsOf: symbol)
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> randomlySelectOption: symbol [
	^ GPRandom instance randomlySelect: (self optionsOf: symbol)
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> randomlySelectOption: symbol given: configuration [

	| opts weights |
	opts := self optionsOf: symbol.
	weights := configuration optionWeightsOf: symbol.
	
]

{ #category : #'as yet unclassified' }
GPContextFreeGrammar >> replaceValuesOf: node [
	| visitor |
	visitor := GPReplacementVisitor new grammar: self.
	^ node replaceWithValueFrom: visitor
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRule [

	 ^ GPRandom instance randomlySelect: self allButMessageRuleKeys
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRuleGiven: configuration [

	 ^ (configuration keysOfRuleWeights includesAll:
		  self allButMessageRuleKeys) ifFalse: [ self selectKeyRule ] ifTrue: [ 
	  GPRandom instance randomlySelectGivenProbabilities:
		   configuration rulesWeights ]
]

{ #category : #'collecting leaves' }
GPContextFreeGrammar >> selectKeyRuleGiven: configuration depth: depth and: ruleKeys [

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
