Class {
	#name : #GPBool,
	#superclass : #GPAbstractExpression,
	#instVars : [
		'logicValue'
	],
	#category : #'GeneticProgramming-Examples'
}

{ #category : #accessing }
GPBool class >> value: boolean [
	^ self new logicValue: boolean
]

{ #category : #controlling }
GPBool >> and: bool [

	 ^ self class new logicValue: (logicValue and: [ bool logicValue ])
]

{ #category : #accessing }
GPBool >> logicValue [
	^ logicValue
]

{ #category : #accessing }
GPBool >> logicValue: anObject [
	logicValue := anObject
]

{ #category : #controlling }
GPBool >> or: bool [

	 ^ self class new logicValue: (logicValue or: [ bool logicValue ])
]
