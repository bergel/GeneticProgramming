Class {
	#name : #GPAssertionFitnessFunction,
	#superclass : #GPMultiObjectiveFitnessFunction,
	#instVars : [
		'weights'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #comparing }
GPAssertionFitnessFunction >> < other [
	self assert: other class = self class.
	^ (self objectiveAt: 'nTestErrors') < (other objectiveAt: 'nTestErrors')  
		ifTrue: [ true ] 
		ifFalse: [ (self objectiveAt: 'nTestErrors') = (other objectiveAt: 'nTestErrors')
			ifTrue: [ (self objectiveAt: 'nRandomErrors') < (other objectiveAt: 'nRandomErrors') ] 
			ifFalse: [ false ] ]
]

{ #category : #comparing }
GPAssertionFitnessFunction >> = other [
	self assert: self class == other class.
	^ ((self objectiveAt: 'nTestErrors') = (other objectiveAt: 'nTestErrors')) 
		and: [ (self objectiveAt: 'nRandomErrors') = (other objectiveAt: 'nRandomErrors') ]
]

{ #category : #comparing }
GPAssertionFitnessFunction >> > other [
	self assert: other class = self class.
	^ (self objectiveAt: 'nTestErrors') > (other objectiveAt: 'nTestErrors')  
		ifTrue: [ true] 
		ifFalse: [ (self objectiveAt: 'nTestErrors') = (other objectiveAt: 'nTestErrors')
			ifTrue: [ (self objectiveAt: 'nRandomErrors') > (other objectiveAt: 'nRandomErrors') ] 
			ifFalse: [ false ] ]
]

{ #category : #converting }
GPAssertionFitnessFunction >> asNumber [ 
	^ (((self objectiveAt: 'nTestErrors') * (weights at: 'nTestErrors' ifAbsent: [ 1 ])) + ((self objectiveAt: 'nRandomErrors') * (weights at: 'nRandomErrors' ifAbsent: [ 1 ]))) asFloat
]

{ #category : #initialization }
GPAssertionFitnessFunction >> initialize [ 
	super initialize.
	weights := Dictionary new
]

{ #category : #'as yet unclassified' }
GPAssertionFitnessFunction >> weightAt: string put: aNumber [
	self assert: (dictObjective includesKey: string).
	self assert: aNumber isNumber.
	weights at: string put: aNumber
]
