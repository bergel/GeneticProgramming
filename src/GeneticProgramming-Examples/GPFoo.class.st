Class {
	#name : #GPFoo,
	#superclass : #GPAbstractExpression,
	#category : #'GeneticProgramming-Examples'
}

{ #category : #'public access' }
GPFoo >> bar: aValue [

	 ^ self foo: aValue bar: 29
]

{ #category : #'public access' }
GPFoo >> foo: aValue [

	 ^ aValue
]

{ #category : #'public access' }
GPFoo >> foo: aValue bar: anotherValue [

	 ^ aValue + anotherValue
]
