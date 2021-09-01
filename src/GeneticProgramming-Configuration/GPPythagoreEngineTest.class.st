Class {
	#name : #GPPythagoreEngineTest,
	#superclass : #GPAbstactEngineTest,
	#category : #'GeneticProgramming-Configuration-Pythagore'
}

{ #category : #initialization }
GPPythagoreEngineTest >> configurationClass [
	^ GPPythagoreConfiguration
]

{ #category : #tests }
GPPythagoreEngineTest >> testSolution [

	| c i1 i2 i3 i4 i5 |
	c := configuration.
	i1 := c multNode nodeChildren: { 
			      c newTerminalA.
			      c newTerminalA }.
	i2 := c multNode nodeChildren: { 
			      c newTerminalB.
			      c newTerminalB }.
	i3 := c multNode nodeChildren: { 
			      c newTerminalC.
			      c newTerminalC }.
	i4 := c sumNode nodeChildren: { 
			      i1.
			      i2 }.
	i5 := c subNode nodeChildren: { 
			      i4.
			      i3 }.

	self
		assert: (engine distanceFromSolutionOf: i5) fitnessValue
		equals: 0
]
