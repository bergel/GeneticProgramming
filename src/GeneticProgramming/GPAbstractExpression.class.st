Class {
	#name : #GPAbstractExpression,
	#superclass : #Object,
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #'public access' }
GPAbstractExpression >> evaluate: collection with: context [

	 ^ self subclassResponsibility
]
