Class {
	#name : #GPGrammar,
	#superclass : #Object,
	#instVars : [
		'rules'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #accessing }
GPGrammar >> at: symbol [
	^ rules at: symbol
]

{ #category : #accessing }
GPGrammar >> at: symbol put: collection evaluationBlock: evaluationBlock and: printBlock [
	(self createRule: symbol) addSequence: collection;
		evaluationBlock: evaluationBlock;
		printBlock: printBlock
]

{ #category : #accessing }
GPGrammar >> at: key putListOf: identifier evaluationBlock: evaluationBlock and: printBlock [
	(self createRule: key)
		isList: true;
		addToSequence: identifier;
		evaluationBlock: evaluationBlock;
		printBlock: printBlock 
]

{ #category : #accessing }
GPGrammar >> at: key putValues: list evaluationBlock: evaluationBlock and: printBlock [
	(self createRule: key) addValues: list;
		evaluationBlock: evaluationBlock;
		printBlock: printBlock
]

{ #category : #creating }
GPGrammar >> createRule: ruleName [
	| rule |
	rule := GPRule name: ruleName.
	rules at: ruleName 
		ifPresent: [ :collection | collection add: rule ]
		ifAbsentPut: [ OrderedCollection new add: rule; yourself ].
	^ rule
]

{ #category : #'public access' }
GPGrammar >> evaluate: anObject [
	^ [(self nodeOf: anObject) evaluateUsing: self] on: Error do: [ nil ]
]

{ #category : #initialization }
GPGrammar >> initialize [ 
	rules := Dictionary new
]

{ #category : #transitions }
GPGrammar >> nodeOf: anObject [
	| stack |
	stack := Stack new.
	^ rules values flattened
		detect: [ :rule | rule isValid: anObject having: stack and: self ]
		ifFound: [ :rule | | newStack queue |
			newStack := Stack new.
			queue := WaitfreeQueue new.
			1 to: stack size do: [:n | newStack push: stack pop ].
			newStack flattened do: [ :v | queue nextPut: v ].
			rule nodeOf: anObject having: queue and: self ]
		ifNone: [ nil ]
]

{ #category : #transitions }
GPGrammar >> ruleNameOf: anObject [
	| stack |
	stack := Stack new.
	^ rules values flattened
		detect: [ :rule | rule isValid: anObject having: stack and: self ]
		ifFound: [ :rule | rule ruleName ]
		ifNone: [ nil ]
]
