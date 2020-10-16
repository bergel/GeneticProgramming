Class {
	#name : #GPContextFreeGrammar,
	#superclass : #Object,
	#instVars : [
		'rules',
		'options'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #adding }
GPContextFreeGrammar >> addLeafRule: symbol withValues: collection [

	 rules
		 at: symbol
		 ifAbsentPut: [ 
		 self createNode: symbol ofClass: GPLiteralNode withSequence: #(  ) ].
	 self addOptions: collection of: symbol
]

{ #category : #adding }
GPContextFreeGrammar >> addMessageRule: symbol withValues: collection [

	 rules
		 at: symbol
		 ifAbsentPut: [ 
		 self createNode: symbol ofClass: GPMessageNode withSequence: #(  ) ].
	 self addOptions: collection of: symbol
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

	rules at: symbol ifAbsentPut: [ 
		self
			createNode: symbol
			ofClass: GPNode
			type: aClass
			withSequence: #(  ) ].
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
GPContextFreeGrammar >> addRule: symbol withOptions: collection [
	collection do: [ :e | self addRule: symbol redirectingTo: e ]
]

{ #category : #adding }
GPContextFreeGrammar >> addRule: key withSequence: sequence [

	 rules
		 at: key
		 ifAbsentPut: [ 
		 self createNode: key ofClass: GPNode withSequence: #(  ) ].
	 self addOptions:
		 (Array with: (self createNode: key ofClass: GPNode withSequence: sequence)) of: key
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
			   (assoc value isMemberOf: GPLiteralNode) and: [ 
				   (symbols includes: assoc key) not ] ]
		   thenCollect: [ :assoc | assoc key ]
]

{ #category : #adding }
GPContextFreeGrammar >> createNode: symbol ofClass: classNode type: aClass withSequence: sequence [

	^ classNode new
		  id: symbol;
		   type: aClass;
		  children: (sequence collect: [ :c | GPNode new id: c ])
]

{ #category : #adding }
GPContextFreeGrammar >> createNode: symbol ofClass: aClass withSequence: sequence [
	^ aClass new 
		id: symbol;
		children: (sequence collect: [:c | GPNode new id: c])
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
GPContextFreeGrammar >> expandFrom: axiom given: configuration [

	 ^ rules
		   at: axiom
		   ifPresent: [ :node | 
			   node expandGiven: self and: configuration]
		   ifAbsent: [ nil ]
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
	 options := Dictionary new
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
GPContextFreeGrammar >> replaceValuesOf: node [
	| visitor |
	visitor := GPReplacementVisitor new grammar: self.
	^ node replaceWithValueFrom: visitor
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRule [

	 ^ GPRandom instance selectRandomly: self allButMessageRuleKeys
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRuleGiven: configuration [

	 ^ (configuration keysOfRuleWeights includesAll:
		  self allButMessageRuleKeys) ifFalse: [ self selectKeyRule ] ifTrue: [ 
	  GPRandom instance selectRandomlyGivenProbabilities:
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
		   ifEmpty: [ GPRandom instance selectRandomly: newCollection ]
		   ifNotEmpty: [ 
			   GPRandom instance selectRandomlyGivenProbabilities:
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
