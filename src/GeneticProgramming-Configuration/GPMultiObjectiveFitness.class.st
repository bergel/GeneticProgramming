Class {
	#name : #GPMultiObjectiveFitness,
	#superclass : #Object,
	#instVars : [
		'dictFunction',
		'dictObjective'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #comparing }
GPMultiObjectiveFitness >> < other [
	self assert: other class = self class.
	^ dictFunction at: '<' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]
]

{ #category : #comparing }
GPMultiObjectiveFitness >> = other [
	^ dictFunction at: '=' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]
]

{ #category : #comparing }
GPMultiObjectiveFitness >> > other [
	self assert: other class = self class.
	^ dictFunction at: '>' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]
]

{ #category : #adding }
GPMultiObjectiveFitness >> addFunctions: collection [
	self assert: collection notEmpty.
	self assert: (collection isDictionary).
	dictFunction addAll: collection
]

{ #category : #adding }
GPMultiObjectiveFitness >> addObjective: association [
	self assert: association isAssociation.
	dictObjective add: association
]

{ #category : #converting }
GPMultiObjectiveFitness >> asNumber [ 	
	^ dictFunction at: 'asNumber' 
		ifPresent: [:block | block valueWithEnoughArguments: (Array with: self) ]
		ifAbsent: [ dictObjective values sum ]
]

{ #category : #initialization }
GPMultiObjectiveFitness >> initialize [ 
	dictFunction := Dictionary new.
	dictObjective := Dictionary new
]

{ #category : #accessing }
GPMultiObjectiveFitness >> objectiveAt: key [
	self assert: (dictObjective notEmpty and: [ dictObjective includesKey: key ]).
	^ dictObjective at: key
]

{ #category : #'as yet unclassified' }
GPMultiObjectiveFitness >> objectives [
	^ dictObjective associations 
]

{ #category : #printing }
GPMultiObjectiveFitness >> printOn: stream [
	dictObjective associationsDo: [ :assoc | 
		stream nextPutAll: assoc key;
		nextPutAll: '->';
		nextPutAll: assoc value asString;
		nextPut: $, ]
]

{ #category : #asserting }
GPMultiObjectiveFitness >> shouldTerminate [
	^ dictFunction at: 'shouldTerminate' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self) ]
		ifAbsent: [ Error signal: 'Does not have a condition termination' ]
]
