Class {
	#name : #GPAbstractExpression,
	#superclass : #Object,
	#category : #'GeneticProgramming-Examples'
}

{ #category : #'public access' }
GPAbstractExpression >> evaluate: collection with: context [

	 ^ self subclassResponsibility
]
