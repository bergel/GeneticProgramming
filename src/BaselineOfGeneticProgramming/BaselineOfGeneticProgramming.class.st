Class {
	#name : #BaselineOfGeneticProgramming,
	#superclass : #BaselineOf,
	#category : #BaselineOfGeneticProgramming
}

{ #category : #baselines }
BaselineOfGeneticProgramming >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				package: 'GeneticProgramming-Examples';
				package: 'GeneticProgramming'
					with: [ spec requires: #('GeneticProgramming-Examples') ] ].
]
