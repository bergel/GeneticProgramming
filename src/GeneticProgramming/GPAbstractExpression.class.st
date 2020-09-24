Class {
	#name : #GPAbstractExpression,
	#superclass : #Object,
	#category : #'GeneticProgramming-Interpreter'
}

{ #category : #'public access' }
GPAbstractExpression >> evaluate: context [
	^ self subclassResponsibility 
]
