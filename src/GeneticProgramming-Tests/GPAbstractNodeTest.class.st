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
	| newNode random |
	random := GPRandom seed: 1.
	newNode := aNode deepCopy.
	(random shuffleElementsOf: (newNode withAllChildren)) 
		detect: [ :child | child isLeaf ]
		ifFound: [:child | child nodeValue: (child isSelectorNode ifTrue: [child nodeValue, 's'] ifFalse: [child nodeValue + 5]) ].
	self deny: aNode print equals: newNode print
]
