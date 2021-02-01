Extension { #name : #GPEngine }

{ #category : #'*GeneticProgramming-Visualization' }
GPEngine >> gtInspectorViewIn: composite [
	<gtInspectorPresentationOrder: -10>
	^ composite roassal3
		title: 'Evolution Fitness';
		initializeCanvas: [ self visualize ]
]

{ #category : #'*GeneticProgramming-Visualization' }
GPEngine >> visualize [
	| c d |
	c := RSChart new.
	d := RSLinePlot new.
	d y: {logs first bestFitnessValue + 0.01},(logs collect: #bestFitnessValue).
	c addPlot: d.
	d := RSLinePlot new.
	d color: Color red.
	d y: {logs first worstFitnessValue + 0.01},(logs collect: #worstFitnessValue).
	c addPlot: d.
	c title: 'Fitness'.
	c addDecoration: RSVerticalTick new.
	c addDecoration: RSHorizontalTick new.
	c build.
	^ c canvas
]
