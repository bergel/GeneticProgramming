Class {
	#name : #GPAbstractNodeTest,
	#superclass : #TestCase,
	#category : #'GeneticProgramming-Tests'
}

{ #category : #running }
GPAbstractNodeTest >> setUp [ 
	GPRandom seed: 1
]

{ #category : #tests }
GPAbstractNodeTest >> testDeepCopy: aNode [
	| newNode |
	newNode := aNode deepCopy.
	(GPRandom instance shuffleElementsOf: (newNode withAllChildren)) 
		detect: [ :child | child isLeaf ]
		ifFound: [:child | child nodeValue: (child isSelectorNode ifTrue: [child nodeValue, 's'] ifFalse: [child nodeValue + 5]) ].
	self deny: aNode print equals: newNode print
]
