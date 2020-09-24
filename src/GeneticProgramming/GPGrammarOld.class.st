Class {
	#name : #GPGrammarOld,
	#superclass : #Object,
	#instVars : [
		'rules'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #accessing }
GPGrammarOld >> at: symbol [
	^ rules at: symbol
]

{ #category : #accessing }
GPGrammarOld >> at: symbol put: collection evaluationBlock: evaluationBlock and: printBlock [
	(self createRule: symbol) addSequence: collection;
		evaluationBlock: evaluationBlock;
		printBlock: printBlock
]

{ #category : #accessing }
GPGrammarOld >> at: key putListOf: identifier evaluationBlock: evaluationBlock and: printBlock [
	(self createRule: key)
		isList: true;
		addToSequence: identifier;
		evaluationBlock: evaluationBlock;
		printBlock: printBlock 
]

{ #category : #accessing }
GPGrammarOld >> at: key putValues: list evaluationBlock: evaluationBlock and: printBlock [
	(self createRule: key) addValues: list;
		evaluationBlock: evaluationBlock;
		printBlock: printBlock
]

{ #category : #creating }
GPGrammarOld >> createRule: ruleName [
	| rule |
	rule := GPRuleOld name: ruleName.
	rules at: ruleName 
		ifPresent: [ :collection | collection add: rule ]
		ifAbsentPut: [ OrderedCollection new add: rule; yourself ].
	^ rule
]

{ #category : #'public access' }
GPGrammarOld >> evaluate: anObject [

	^ [ (self nodeOf: anObject) evaluateUsing: self ]
		  on: Error
		  do: [ :error |
			  nil ]
]

{ #category : #initialization }
GPGrammarOld >> initialize [ 
	rules := Dictionary new
]

{ #category : #transitions }
GPGrammarOld >> nodeOf: anObject [
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
GPGrammarOld >> ruleNameOf: anObject [
	| stack |
	stack := Stack new.
	^ rules values flattened
		detect: [ :rule | rule isValid: anObject having: stack and: self ]
		ifFound: [ :rule | rule ruleName ]
		ifNone: [ nil ]
]
