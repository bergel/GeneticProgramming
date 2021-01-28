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
GPAbstractNode >> shapes [

	^ (self withAllChildren collect: [ :child | 
		   RSComposite new
			   model: child;
			   addShape: (RSEllipse new
					    extent: 20 @ 20;
					    color: (Color r: 0.5298142717497556 g: 0.8074291300097751 b: 0.9804496578690127);
					    border: (RSBorder new
							     color: (Color
									      r: 0.2316715542521994
									      g: 0.5141739980449658
									      b: 0.7409579667644184);
							     yourself);
					    @ RSDraggable);
			   addShape: (RSLabel new
					    text: child id;
					    color: Color black;
					    bold;
					    fontSize: 2);
			   padding: 10;
			   yourself ]) asOrderedCollection
]

{ #category : #'*GeneticProgramming-Visualization' }
GPAbstractNode >> visualize [
	 | canvas eb |
			  canvas := RSCanvas new.
			  canvas addAll: self shapes.
			  eb := RSEdgeBuilder line
				        color: (Color
						         r: 0.2316715542521994
						         g: 0.5141739980449658
						         b: 0.7409579667644184);
				        canvas: canvas;
				        connectToAll: #children.
			  canvas edges pushBack.
			  RSTreeLayout new
				  verticalGap: 10;
				  on: canvas nodes.
			  canvas @ RSCanvasController.
	^ canvas
]
