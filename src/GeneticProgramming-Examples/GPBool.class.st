Class {
	#name : #GPBool,
	#superclass : #GPAbstractExpression,
	#category : #'GeneticProgramming-Examples'
}

{ #category : #'public access' }
GPBool >> evaluate: collection with: context [

	 ^ context selectRandomly: #(true false)
]
