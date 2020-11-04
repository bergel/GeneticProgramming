Extension { #name : #RBProgramNode }

{ #category : #'*GeneticProgramming' }
RBProgramNode >> gtInspectorCanvasIn: composite [

	<gtInspectorPresentationOrder: 1>
	| m |
	m := RSMondrian new.
	"m shape circle. "
	m nodes: self allChildren forEach: [ :n | 
		m shape label color: Color white.
		m nodes: (Array with: n class name) ].
	m line
		color: (Color r: 59 / 255 g: 131 / 255 b: 189 / 255);
		width: 0.5;
		connectToAll: #children.
	m layout tree.
	^ m gtInspectorViewIn: composite
]
