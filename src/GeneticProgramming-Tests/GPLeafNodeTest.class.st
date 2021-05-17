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
GPLeafNodeTest >> testReplaceBy [
	| node replacement |
	node := GPLeafNode new id: #E; type: RBLiteralNode; nodeValue: 1; printBlock: [ :n :ctx | n nodeValue asString ].
	replacement := GPLeafNode new id: #E; type: RBLiteralNode; nodeValue: 5; printBlock: [ :n :ctx | n nodeValue asString ].
	self assert: node print equals: '1'.
	self assert: replacement print equals: '5'.
	node replaceBy: replacement.
	self assert: node print equals: '5'
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
