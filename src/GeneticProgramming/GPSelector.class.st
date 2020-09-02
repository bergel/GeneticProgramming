Class {
	#name : #GPSelector,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'GeneticProgramming-AST'
}

{ #category : #accessing }
GPSelector class >> name: aString [
	^ self new name: aString 
	
]

{ #category : #copying }
GPSelector >> deepCopy [ 
	^ self class new 
		name: name 
]

{ #category : #accessing }
GPSelector >> name [
	^ name
]

{ #category : #accessing }
GPSelector >> name: anObject [
	name := anObject
]

{ #category : #printing }
GPSelector >> printOn: stream [
	stream nextPutAll: name
]
