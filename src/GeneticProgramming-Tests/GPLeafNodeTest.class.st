Class {
	#name : #GPLeafNodeTest,
	#superclass : #GPAbstractNodeTest,
	#category : #'GeneticProgramming-Tests'
}

{ #category : #tests }
GPLeafNodeTest >> testDeepCopy [
	^ self testDeepCopy: (GPLeafNode new nodeValue: 3; id: #F; printBlock: [:n :ctx | n nodeValue asString])
]

{ #category : #tests }
GPLeafNodeTest >> testSelectOptionNodeGiven [
	| opts config node |
	config := GPConfiguration new
		forRule: #E putWeights: #(10 1).
	opts := #(18 3).
	node := GPLeafNode new id: #E; printBlock: [ :n :ctx | n nodeValue: (config selectValue: opts forRule: #E) ].
	self assert: node print nodeValue equals: 18
	 
]
