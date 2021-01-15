Extension { #name : #GPAbstractNode }

{ #category : #'*GeneticProgramming-Visualization' }
GPAbstractNode >> gtInspectorViewIn: composite [

	<gtInspectorPresentationOrder: -1>
	^ composite roassal3
		  title: [ 'MetaDescription Tree' ];
		  initializeCanvas: [ 
			  self visualize ]
]
