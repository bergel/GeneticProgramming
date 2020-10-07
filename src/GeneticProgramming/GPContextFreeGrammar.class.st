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
GPContextFreeGrammar >> addRule: symbol redirectingTo: anotherSymbol [

	 self
		 addRule: symbol
		 withSequence: (Array with: anotherSymbol)
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
GPContextFreeGrammar >> expandUsing: configuration [

	 ^ self
		   expandFrom:
		   (self
			    selectKeyRuleGiven: configuration)
		   given: configuration
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
GPContextFreeGrammar >> optionsOf: symbol [

	 ^ options at: symbol
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRule [

	 ^ GPRandom instance selectRandomly: self allButMessageRuleKeys
]

{ #category : #selecting }
GPContextFreeGrammar >> selectKeyRuleGiven: configuration [

	 (configuration keysOfRuleWeights includesAll:
		  self allButMessageRuleKeys ) ifFalse: [ 
		 self error: 'all rules must have assigned a weight' ].
	 ^ GPRandom instance selectRandomlyGivenProbabilities:
		   configuration rulesWeights
]
