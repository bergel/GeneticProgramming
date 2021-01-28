Class {
	#name : #GPCollectionNodeTest,
	#superclass : #GPAbstractNodeTest,
	#category : #'GeneticProgramming-Tests'
}

{ #category : #tests }
GPCollectionNodeTest >> testAst [
	| node ast |
	node := GPCollectionNode new 
		id: #Stms;
		children: (OrderedCollection new 
			add: (GPNode new id: #F; type: RBLiteralNode; nodeValue: 4);
			add: (GPNode new id: #Var; type: RBVariableNode; nodeValue: #a);
			add: (GPNode new id: #G; type: RBLiteralNode; nodeValue: 109);
			yourself ).
	ast := node ast.
	self assert: (RBParser parseExpression: '4. a. 109') equals: ast
]

{ #category : #tests }
GPCollectionNodeTest >> testDeepCopy [
	^ self testDeepCopy: (GPCollectionNode new id: #Args; 
		children: (OrderedCollection new 
			add: (GPLeafNode new id: #F; nodeValue: 5; printBlock: [:n :ctx | n nodeValue asString ]);
			add: (GPSelectorNode new id: #Mess; nodeValue: #div; printBlock: [:n :ctx | n nodeValue]);
			add: (GPNode new id: #E); yourself );
		printBlock: [:n :ctx | n nodeValue asString])
]
