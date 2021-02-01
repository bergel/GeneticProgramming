Extension { #name : #RBProgramNode }

{ #category : #'*GeneticProgramming-Visualization' }
RBProgramNode >> depth [

	parent ifNil: [ ^ 1 ].
	^ parent depth + 1.
]

{ #category : #'*GeneticProgramming-Visualization' }
RBProgramNode >> gtInspectorCanvasIn: composite [

	<gtInspectorPresentationOrder: 1>
	^ composite roassal3
		  title: [ 'AST Node' ];
		  initializeCanvas: [ 
			  self visualize ]
]

{ #category : #'*GeneticProgramming-Visualization' }
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
		   | group texts cName max composite labels |
		   texts := child formattedCode splitOn: Character cr.
		   cName := child class name.
		   max := ((texts collect: #size) max max: cName size) * 8.
		   group := RSGroup new
			            add: (RSComposite new
					             addShape: (RSBox new
							              color: boxColor;
							              extent: max @ 20;
							              border: (RSBorder new
									               color: borderColor;
									               yourself));
					             addShape: (RSLabel new
							              text: cName;
							              color: Color black;
							              fontSize: 10);
					             padding: 0;
					             yourself);
			            yourself.
		   composite := RSComposite new.
		   composite addShape: (RSBox new
				    extent: max @ (texts size * 20);
				    color: boxColor;
				    border: (RSBorder new
						     color: borderColor;
						     yourself)).
		   labels := (texts collect: [ :str | 
			              RSLabel new
				              text: str;
				              color: Color black;
				              fontSize: 10 ]) asGroup.
		   RSVerticalLineLayout new
			   gapSize: 1.5;
			   on: labels.
		   composite addShape: (RSComposite new
				    shapes: labels;
				    position: 0 @ 0;
				    yourself).
		   composite padding: 0.
		   group add: composite.
		   RSVerticalLineLayout new
			   gapSize: 0;
			   on: group.
		   RSComposite new
			   model: child;
			   shapes: (group collect: #yourself);
			   padding: 10;
			   yourself ]) asOrderedCollection
]

{ #category : #'*GeneticProgramming-Visualization' }
RBProgramNode >> visualize [
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
			  canvas @ RSCanvasController.
	^ canvas
]
