Extension { #name : #RBProgramNode }

{ #category : #'*GeneticProgramming' }
RBProgramNode >> gtInspectorCanvasIn: composite [

	<gtInspectorPresentationOrder: 1>
	^ composite roassal3
		  title: [ 'AST Node' ];
		  initializeCanvas: [ 
			  | canvas eb |
			  canvas := RSCanvas new.
			  canvas addAll: self shapesOfNodes.
			  eb := RSEdgeBuilder line
				        color: (Color
						         r: 0.2316715542521994
						         g: 0.5141739980449658
						         b: 0.7409579667644184);
				        canvas: canvas;
				        connectFrom: #parent.
			  canvas edges pushBack.
			  RSTreeLayout new
				  verticalGap: 10;
				  on: canvas nodes.
			  canvas @ RSCanvasController ]
]

{ #category : #'*GeneticProgramming' }
RBProgramNode >> shapesOfNodes [

	| boxColor borderColor visitor |
	boxColor := Color
		            r: 0.5298142717497556
		            g: 0.8074291300097751
		            b: 0.9804496578690127.
	borderColor := Color
		               r: 0.2316715542521994
		               g: 0.5141739980449658
		               b: 0.7409579667644184.
	visitor := GPCollectorDataVisitor new.
	^ (self allChildren collect: [ :child | 
		   | group text cName max |
		   child acceptVisitor: visitor.
		   text := visitor string.
		   cName := child class name.
		   max := text size max: cName size.
		   group := RSGroup new
			            add: (RSComposite new
					             addShape: (RSBox new
							              color: boxColor;
							              extent: max * 8 @ 20;
							              border: (RSBorder new
									               color: borderColor;
									               yourself);
							              @ RSDraggable);
					             addShape: (RSLabel new
							              text: cName;
							              color: Color black;
							              fontSize: 10);
					             padding: 0;
					             yourself);
			            add: (RSComposite new
					             addShape: (RSBox new
							              extent: max * 8 @ 100;
							              color: boxColor;
							              border: (RSBorder new
									               color: borderColor;
									               yourself);
							              @ RSDraggable);
					             addShape: (RSLabel new
							              text: text;
							              color: Color black;
							              fontSize: 10);
					             padding: 0;
					             yourself);
			            yourself.
		   RSVerticalLineLayout new
			   gapSize: 0;
			   on: group.
		   RSComposite new
			   model: child;
			   shapes: (group collect: #yourself);
			   padding: 10;
			   yourself ]) asOrderedCollection
]
