Class {
	#name : #GPRule,
	#superclass : #Object,
	#instVars : [
		'values',
		'sequence',
		'ruleName',
		'evaluationBlock',
		'printBlock',
		'isList'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #accessing }
GPRule class >> name: string [
	^ self new ruleName: string 
]

{ #category : #adding }
GPRule >> addSequence: symbols [
	sequence := symbols asOrderedCollection 
]

{ #category : #adding }
GPRule >> addToSequence: symbol [
	sequence add: symbol 
]

{ #category : #adding }
GPRule >> addValue: anObject [
	values add: anObject 
]

{ #category : #adding }
GPRule >> addValues: list [
	values addAll: list "flattened" 
]

{ #category : #'node creation' }
GPRule >> collectNodesOf: objects atIndex: index having: ruleIndexes and: grammar [
	| rule referenceName |
	index > objects size ifTrue: [ ^ #() ].
	referenceName := sequence at: (isList ifTrue: [ 1 ] ifFalse: [ index]).
	rule := (self collectReferencedRules: (grammar at: referenceName) on: grammar) at: ruleIndexes nextOrNil.
	^ OrderedCollection new 
		add: (rule nodeOf: (objects at: index) having: ruleIndexes and: grammar);
		addAll: (self collectNodesOf: objects atIndex: index + 1 having: ruleIndexes and: grammar);
		yourself.
]

{ #category : #'collecting leaves' }
GPRule >> collectReferencedRules: rules on: grammar [
	^ (rules collect: [ :rule | rule sequence size == 1 
										ifTrue: [ grammar at: rule sequence first ]
										ifFalse: [ rule ] ]) flattened
]

{ #category : #accessing }
GPRule >> evaluationBlock: aBlock [
	evaluationBlock := aBlock
]

{ #category : #initialization }
GPRule >> initialize [ 
	sequence := OrderedCollection new.
	values := OrderedCollection new.
	isList := false
]

{ #category : #accessing }
GPRule >> isList: boolean [
	isList := boolean 
]

{ #category : #testing }
GPRule >> isValid: collection atIndex: index having: stack and: grammar [
	| indexRule referenceName |
	isList ifFalse: [ collection size == sequence size ifFalse: [ ^ false ] ].
	index > collection size ifTrue: [ ^ true ].
	indexRule := 0.
	referenceName := sequence at: (isList ifTrue: [ 1 ] ifFalse: [ index ] ).
	^ (self collectReferencedRules: (grammar at: referenceName) on: grammar)
		detect: [ :rule | indexRule := indexRule + 1.
			rule isValid: (collection at: index) having: stack and: grammar ] 
		ifFound: [ :rule | 
			rule sequence
				ifEmpty: [ stack push: indexRule ]
				ifNotEmpty: [ | newStack |
					newStack := Stack new.
					1 to: sequence size do: [:n | newStack push: stack pop ].
					stack push: (newStack push: indexRule; yourself) ].
			(self isValid: collection atIndex: index + 1 having: stack and: grammar) ] 
		ifNone: [ false ]
]

{ #category : #testing }
GPRule >> isValid: anObject having: stacks and: grammar [
	^ sequence 
		ifEmpty: [ values includes: anObject ]
		ifNotEmpty: [ anObject isCollection 
			ifTrue: [ self isValid: anObject atIndex: 1 having: stacks and: grammar ]
			ifFalse: [ false ] ]
	
]

{ #category : #evaluating }
GPRule >> nodeOf: anObject having: ruleIndexes and: grammar [
	^ (sequence isEmpty) 
			ifTrue: [ self terminalNodeOf: anObject having: ruleIndexes and: grammar ]
			ifFalse: [ self nonTerminalNodeOf: anObject having: ruleIndexes and: grammar ]
]

{ #category : #evaluating }
GPRule >> nonTerminalNodeOf: collection having: ruleIndexes and: grammar [
	^ GPNode new 
		evaluationBlock: evaluationBlock;
		printBlock: printBlock;
		children: (self collectNodesOf: collection atIndex: 1 having: ruleIndexes and: grammar);
		yourself
]

{ #category : #accessing }
GPRule >> printBlock: aBlock [
	printBlock := aBlock 
]

{ #category : #accessing }
GPRule >> ruleName [
	^ ruleName
]

{ #category : #accessing }
GPRule >> ruleName: string [
	ruleName := string
]

{ #category : #accessing }
GPRule >> sequence [ 
	^ sequence
]

{ #category : #'node creation' }
GPRule >> terminalNodeOf: anObject having: indexes and: grammar [
	^ GPNode new 
		type: anObject;
		evaluationBlock: evaluationBlock;
		printBlock: printBlock;
		yourself
]
