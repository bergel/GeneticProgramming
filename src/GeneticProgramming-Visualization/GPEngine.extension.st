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
	d color: Color red.
	d y: {logs first worstFitnessValue asNumber + 0.01},(logs collect: [:l | l worstFitnessValue asNumber]).
	c addPlot: d.
	d := RSLinePlot new.
	d color: Color green.
	d y: {logs first averageFitness asNumber + 0.01},(logs collect: [:l | l averageFitness asNumber ]).
	c addPlot: d.
	d := RSLinePlot new.
	d y: {logs first bestFitnessValue asNumber + 0.01},(logs collect: [:l | l bestFitnessValue asNumber]).
	c addPlot: d.
	c title: 'Fitness'.
	c addDecoration: RSVerticalTick new.
	c addDecoration: RSHorizontalTick new.
	c build.
	^ c canvas
]
