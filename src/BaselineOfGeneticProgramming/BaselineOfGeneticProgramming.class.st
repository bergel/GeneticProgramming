Class {
	#name : #BaselineOfGeneticProgramming,
	#superclass : #BaselineOf,
	#category : #BaselineOfGeneticProgramming
}

{ #category : #baselines }
BaselineOfGeneticProgramming >> baseline: spec [

	 <baseline>
	 spec for: #common do: [ 
		 spec baseline: 'GPPlay' with: [ spec repository: 'github://bergel/GPPlay:main/src' ].
		 spec baseline: 'Roassal3' with: [ spec loads: #('Full');
			repository: 'github://ObjectProfile/Roassal3' ].
		 spec
			 package: 'GeneticProgramming';
			 package: 'GeneticProgramming-Examples';
			 package: 'GeneticProgramming-Configuration' with: [
				spec requires: #('GeneticProgramming' 'GPPlay') ];
			 package: 'GeneticProgramming-Tests' with: [ 
				 spec requires:
						 #( 'GeneticProgramming' 'GeneticProgramming-Examples' ) ];
			package: 'GeneticProgramming-Visualization' with: [ spec requires: #('Roassal3') ].
		spec 
			group: 'default' with: #('GeneticProgramming-Examples' 'GeneticProgramming-Tests' 'GeneticProgramming-Configuration' );
			group: 'all' with: #( 'GeneticProgramming-Tests' 'GeneticProgramming-Visualization' 'GeneticProgramming-Configuration' ) ]
]
