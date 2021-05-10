Class {
	#name : #GPFitness,
	#superclass : #Object,
	#instVars : [
		'fitnessValue',
		'objective'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #comparing }
GPFitness >> < other [
	self assert: self class == other class.
	^ fitnessValue < other fitnessValue 
]

{ #category : #comparing }
GPFitness >> = other [
	^ self class = other class and: [ fitnessValue = other fitnessValue ] 
]

{ #category : #comparing }
GPFitness >> > other [
	self assert: self class == other class.
	^ fitnessValue > other fitnessValue 
]

{ #category : #accessing }
GPFitness >> fitnessValue [
	^ fitnessValue  
]

{ #category : #accessing }
GPFitness >> fitnessValue: object [
	fitnessValue := object 
]

{ #category : #accessing }
GPFitness >> objective: block [
	self assert: block isBlock.
	objective := block
]

{ #category : #asserting }
GPFitness >> shouldTerminate [ 
	^ objective value: self
]
