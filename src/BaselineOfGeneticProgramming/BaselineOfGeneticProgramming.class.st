Class {
	#name : #BaselineOfGeneticProgramming,
	#superclass : #BaselineOf,
	#category : #BaselineOfGeneticProgramming
}

{ #category : #baselines }
BaselineOfGeneticProgramming >> baseline: spec [

	 <baseline>
	 spec for: #common do: [ 
		 spec
			 package: 'GeneticProgramming';
			 package: 'GeneticProgramming-Examples';
			 package: 'GeneticProgramming-Tests' with: [ 
				 spec requires:
						 #( 'GeneticProgramming' 'GeneticProgramming-Examples' ) ] ]
]
