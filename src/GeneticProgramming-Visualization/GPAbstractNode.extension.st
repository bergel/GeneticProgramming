Extension { #name : #GPAbstractNode }

{ #category : #'*GeneticProgramming-Visualization' }
GPAbstractNode >> gtInspectorViewIn: composite [

	<gtInspectorPresentationOrder: -1>
	^ composite roassal3
		  title: [ 'MetaDescription Tree' ];
		  initializeCanvas: [ 
			  self visualize ]
]

{ #category : #'*GeneticProgramming-Visualization' }
GPAbstractNode >> visualize [

	| canvas eb |
	canvas := RSCanvas new.
	canvas addAll: self allShapes.
	eb := RSEdgeBuilder line
		      color: (Color
				       r: 0.2316715542521994
				       g: 0.5141739980449658
				       b: 0.7409579667644184);
		      canvas: canvas;
		      connectToAll: #nodeChildren.
	canvas edges pushBack.
	RSTreeLayout new
		verticalGap: 10;
		on: canvas nodes.
	canvas @ RSCanvasController.
	^ canvas
]
