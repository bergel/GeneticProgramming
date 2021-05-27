Class {
	#name : #GPFitnessFunction,
	#superclass : #Object,
	#instVars : [
		'fitnessValue',
		'objective'
	],
	#category : #'GeneticProgramming-FitnessFunction'
}

{ #category : #comparing }
GPFitnessFunction >> < other [
	self assert: self class == other class.
	^ fitnessValue < other fitnessValue 
]

{ #category : #comparing }
GPFitnessFunction >> = other [
	^ self class = other class and: [ fitnessValue = other fitnessValue ] 
]

{ #category : #comparing }
GPFitnessFunction >> > other [
	self assert: self class == other class.
	^ fitnessValue > other fitnessValue 
]

{ #category : #converting }
GPFitnessFunction >> asNumber [ 
	^ fitnessValue 
]

{ #category : #accessing }
GPFitnessFunction >> fitnessValue [
	^ fitnessValue  
]

{ #category : #accessing }
GPFitnessFunction >> fitnessValue: object [
	fitnessValue := object 
]

{ #category : #accessing }
GPFitnessFunction >> objective: block [
	self assert: block isBlock.
	objective := block
]

{ #category : #asserting }
GPFitnessFunction >> shouldTerminate [ 
	^ objective value: self
]
