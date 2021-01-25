Class {
	#name : #GPMessageNodeTest,
	#superclass : #GPAbstractNodeTest,
	#category : #'GeneticProgramming-Tests'
}

{ #category : #tests }
GPMessageNodeTest >> testDeepCopy [
	^ self testDeepCopy: (GPSelectorNode new nodeValue: #plus; 
		id: #Add; 
		printBlock: [:n :ctx | n nodeValue ])
]

{ #category : #tests }
GPMessageNodeTest >> testSelectOptionNodeGiven [
	| opts config node |
	config := GPConfiguration new
		forRule: #M putWeights: #(2 8).
	opts := #(#+ #-).
	node := GPSelectorNode new id: #M; printBlock: [ :n :ctx | n nodeValue: (config selectValue: opts forRule: #M) ].
	self assert: node print nodeValue equals: '+'
	 
]
