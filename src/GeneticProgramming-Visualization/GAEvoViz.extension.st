Extension { #name : #GAEvoViz }

{ #category : #'*GeneticProgramming-Visualization' }
GAEvoViz >> addSurvivor: object on: collection using: set and: integer [
	| selected association |
	association := object generation -> object position.
	selected := object generation == integer.
	selected ifFalse: [ 
		object childrenByGeneration do: [ :each | | included |
			included := (set includes: each generation -> each position) or: [ 
				self addSurvivor: each on: collection using: set and: integer ].
			selected := selected or: [ included ] ]	
	].
	selected ifTrue: [ 
		(set includes: association) 
			ifFalse: [ 
				set add: association.
				collection add: object ].
			^ true	
	].
	^ false
]
