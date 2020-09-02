Class {
	#name : #GPAbstractNode,
	#superclass : #Object,
	#category : #'GeneticProgramming-Arithmetic'
}

{ #category : #'public access' }
GPAbstractNode >> evaluate [ 
	^ self subclassResponsibility 
]
