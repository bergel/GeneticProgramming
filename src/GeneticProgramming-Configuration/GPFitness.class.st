Class {
	#name : #GPFitness,
	#superclass : #Object,
	#instVars : [
		'dictFunction',
		'dictObjective'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #comparing }
GPFitness >> < other [
	self assert: other class = self class.
	^ dictFunction at: '<' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]
]

{ #category : #comparing }
GPFitness >> = other [
	other isNumber ifTrue: [ ^ dictObjective values sum = other ].
	self halt.
	^ dictFunction at: '=' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]
]

{ #category : #comparing }
GPFitness >> > other [
	self assert: other class = self class.
	^ dictFunction at: '>' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]
]

{ #category : #adding }
GPFitness >> addFunctions: collection [
	self assert: collection notEmpty.
	self assert: (collection isDictionary).
	dictFunction addAll: collection
]

{ #category : #adding }
GPFitness >> addObjective: association [
	self assert: association isAssociation.
	dictObjective add: association
]

{ #category : #initialization }
GPFitness >> initialize [ 
	dictFunction := Dictionary new.
	dictObjective := Dictionary new
]

{ #category : #accessing }
GPFitness >> objectiveAt: key [
	self assert: (dictObjective notEmpty and: [ dictObjective includesKey: key ]).
	^ dictObjective at: key
]

{ #category : #printing }
GPFitness >> printOn: stream [
	dictObjective associationsDo: [ :assoc | 
		stream nextPutAll: assoc key;
		nextPutAll: '->';
		nextPutAll: assoc value asString;
		nextPut: $, ]
]

{ #category : #asserting }
GPFitness >> shouldTerminate [
	^ dictFunction at: 'shouldTerminate' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self) ]
		ifAbsent: [ Error signal: 'Does not have a condition termination' ]
]
