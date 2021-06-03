Class {
	#name : #GPMultiObjectiveFitnessFunction,
	#superclass : #Object,
	#instVars : [
		'dictObjective'
	],
	#category : #'GeneticProgramming-FitnessFunction'
}

{ #category : #comparing }
GPMultiObjectiveFitnessFunction >> < other [
	^ self subclassResponsibility 
	"self assert: other class = self class.
	^ dictFunction at: '<' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]"
]

{ #category : #comparing }
GPMultiObjectiveFitnessFunction >> = other [
	^ self subclassResponsibility 
	"^ dictFunction at: '=' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]"
]

{ #category : #comparing }
GPMultiObjectiveFitnessFunction >> > other [
	^ self subclassResponsibility 
	"self assert: other class = self class.
	^ dictFunction at: '>' 
		ifPresent: [ :block | block valueWithEnoughArguments: (Array with: self with: other) ]
		ifAbsent: [ Error signal: 'It can not be compared' ]"
]

{ #category : #adding }
GPMultiObjectiveFitnessFunction >> addFunctions: collection [
	self assert: collection notEmpty.
	self assert: (collection isDictionary).
	dictFunction addAll: collection
]

{ #category : #adding }
GPMultiObjectiveFitnessFunction >> addObjective: association [
	self assert: association isAssociation.
	dictObjective add: association
]

{ #category : #converting }
GPMultiObjectiveFitnessFunction >> asNumber [ 	
	^ self subclassResponsibility 
]

{ #category : #initialization }
GPMultiObjectiveFitnessFunction >> initialize [ 
	"dictFunction := Dictionary new."
	dictObjective := Dictionary new
]

{ #category : #accessing }
GPMultiObjectiveFitnessFunction >> objectiveAt: key [
	self assert: (dictObjective notEmpty and: [ dictObjective includesKey: key ]).
	^ dictObjective at: key
]

{ #category : #adding }
GPMultiObjectiveFitnessFunction >> objectiveAt: string put: aNumber [
	self assert: string isString.
	self assert: aNumber isNumber.
	dictObjective at: string put: aNumber
]

{ #category : #'as yet unclassified' }
GPMultiObjectiveFitnessFunction >> objectives [
	^ dictObjective associations 
]

{ #category : #printing }
GPMultiObjectiveFitnessFunction >> printOn: stream [
	dictObjective associationsDo: [ :assoc | 
		stream nextPutAll: assoc key;
		nextPutAll: '->';
		nextPutAll: assoc value asString;
		nextPut: $, ]
]

{ #category : #asserting }
GPMultiObjectiveFitnessFunction >> shouldTerminate [
	^ self subclassResponsibility 
]
