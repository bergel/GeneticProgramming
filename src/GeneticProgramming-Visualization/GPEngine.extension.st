Extension { #name : #GPEngine }

{ #category : #'*GeneticProgramming-Visualization' }
GPEngine >> gtInspectorViewIn: composite [
	"<gtInspectorPresentationOrder: -10>
	composite roassal2
		title: 'View';
		initializeView: [ self visualize ]"
]

{ #category : #'*GeneticProgramming-Visualization' }
GPEngine >> visualize [

	"| g d |
	g := RTGrapher new.
	d := RTData new.
	d connectColor: Color blue.
	d points: logs.
	d y: #bestFitnessValue.
	g add: d.
	
	d := RTData new.
	d connectColor: Color red.
	d points: logs.
	d y: #worstFitnessValue.
	g add: d.
	^ g"
]
