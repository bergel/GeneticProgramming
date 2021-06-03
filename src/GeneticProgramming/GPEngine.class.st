Class {
	#name : #GPEngine,
	#superclass : #Object,
	#instVars : [
		'configuration',
		'population',
		'logs'
	],
	#category : #'GeneticProgramming-Core'
}

{ #category : #accessing }
GPEngine >> configuration [
	^ configuration
]

{ #category : #accessing }
GPEngine >> configuration: aGPConfiguration [
	configuration := aGPConfiguration
]

{ #category : #hooks }
GPEngine >> createInitialPopulation [
	population := (1 to: self populationSize)
		collect: [ :i | self createNewIndividual ]
]

{ #category : #evolution }
GPEngine >> createNewGeneration [

	"The argument is a collection of GPNode, each element being the root node of an individual."

	"check if problem solved"

	| i1 i2 newPopulation |
	self pickBestIndividual fitness shouldTerminate ifTrue: [ ^ self ].
	newPopulation := self eliteOfPopulation.
	population size - newPopulation size timesRepeat: [ 
		| number parent newInd indiv |
		number := configuration randomInt: 100.
		number <= 33
			ifTrue: [
				i1 := self tournament.
				i2 := self tournamentDiscarding: i1.
				newInd := configuration crossover: i1 with: i2.
				newInd ifNil: [ newInd := configuration pickBestIndividual: i1 and: i2 ] ]
			ifFalse: [ 
				parent := self tournament.
				newInd := parent deepCopy.
				newInd addParent: parent.
				"self distanceFromSolutionOf: newInd" ].
		number := configuration randomInt: 100.
		number <= 50 ifTrue: [ configuration mutate: newInd.
			"self distanceFromSolutionOf: newInd "].
		self distanceFromSolutionOf: newInd.
		indiv := configuration pickBestConsideringParents: newInd.
		newPopulation add: indiv ].
	population := newPopulation
]

{ #category : #operations }
GPEngine >> createNewIndividual [
	self assert: [ configuration notNil ] description: 'You must set a configuration'.
	^ configuration createNewIndividual

]

{ #category : #operations }
GPEngine >> distanceFromSolutionOf: individual [
	^ configuration distanceFromSolutionOf: individual
]

{ #category : #'as yet unclassified' }
GPEngine >> eliteOfPopulation [ 
	| bestIndividual clonedIndividual |
	bestIndividual := self pickBestIndividual.
	clonedIndividual := bestIndividual deepCopy.
	clonedIndividual addParent: bestIndividual.
	^ OrderedCollection new 
		add: clonedIndividual;
		yourself 
]

{ #category : #hooks }
GPEngine >> execute [
	"
	| e| 
	e := self new.
	e configuration: GPAritConfiguration new.
	e execute.
	"
	| log r |
	self createInitialPopulation.
	(population allSatisfy: #notNil) ifFalse: [ ^ self ].
	r := self rankedIndividuals.
	"population do: [ :ind | Transcript show: ind print, String cr ]."
	log := GPLog new 
		population: population copy;
		generation: 0;
		bestFitnessValue: r first value;
		worstFitnessValue: r last value;
		averageFitness: (r at: (r size / 2) asInteger) value.
	logs add: log.
	(1 to: configuration numberOfGenerations)
		do: [ :gen | 
			| rInds |
			self createNewGeneration.
			(population allSatisfy: #notNil) ifFalse: [ ^ self ].
			"population do: [ :ind | Transcript show: ind print, String cr ]."
			rInds := self rankedIndividuals.
			log := GPLog new.
			log population: population copy.
			log generation: gen.
			log bestFitnessValue: rInds first value.
			log worstFitnessValue: rInds last value.
			log averageFitness: (rInds at: (rInds size / 2) asInteger) value."([(rInds collect: [:ass | ass value asNumber]) sum / rInds size] on: MessageNotUnderstood do: [ rInds last value ])."
			logs add: log.

			"self fitnessOfBestIndividual"
			rInds first value shouldTerminate ifTrue: [ ^ self ] ]
		displayingProgress: [ :gen | 
		'Evolving - Generation ' , gen printString ]
]

{ #category : #accessing }
GPEngine >> fitnessOfAverageIndividual [
	^ self distanceFromSolutionOf: self pickAverageIndividual
]

{ #category : #accessing }
GPEngine >> fitnessOfBestIndividual [
	^ self distanceFromSolutionOf: self pickBestIndividual
]

{ #category : #accessing }
GPEngine >> fitnessOfWorstIndividual [
	^ self distanceFromSolutionOf: self pickWorstIndividual
]

{ #category : #initialization }
GPEngine >> initialize [
	super initialize.
	logs := OrderedCollection new
]

{ #category : #accessing }
GPEngine >> logs [
	^ logs
]

{ #category : #evolution }
GPEngine >> mutation [
	"Return an element, picked randomly from the population, that has been mutated"
	| ind |
	ind := (self randomElementOf: population) "self tournament" deepCopy.
	configuration mutate: ind.
	^ ind
]

{ #category : #evolution }
GPEngine >> negativeTournamentIndex [
	"Return the index of the worst individual from a tournament"
	| fitness worst index |
	fitness := SmallInteger minVal.
	worst := nil.
	2 timesRepeat: [ 
		| competitor i |
		index := configuration randomInt: population size.
		competitor := population at: index.
		i := self distanceFromSolutionOf: competitor.
		i > fitness ifTrue: [ 
			worst := competitor.
			fitness := self distanceFromSolutionOf: competitor ]
	].
	^ index
]

{ #category : #'as yet unclassified' }
GPEngine >> numberOfDifferentIndividuals [
	^ self numberOfDifferentIndividualsIn: self population
]

{ #category : #'as yet unclassified' }
GPEngine >> numberOfDifferentIndividualsIn: setOfIndividuals [
	^ (setOfIndividuals collect: [ :i | i print ]) asSet size
]

{ #category : #'as yet unclassified' }
GPEngine >> pickAverageIndividual [
	"^ (self rankedIndividuals at: population size // 2) key"
	^ (self sortedIndividuals at: population size // 2) key
]

{ #category : #'as yet unclassified' }
GPEngine >> pickBestIndividual [
	"^ self rankedIndividuals first key"
	^ self sortedIndividuals first key
]

{ #category : #'as yet unclassified' }
GPEngine >> pickWorstIndividual [
	"^ self rankedIndividuals last key"
	^ self sortedIndividuals last key
]

{ #category : #accessing }
GPEngine >> population [
	^ population 
]

{ #category : #accessing }
GPEngine >> populationSize [
	^ configuration populationSize
]

{ #category : #'private-random operations' }
GPEngine >> randomElementOf: aCollection [
	^ configuration randomElementOf: aCollection
]

{ #category : #'as yet unclassified' }
GPEngine >> rankedIndividuals [
	"return the list of individuals, sorted as the best match in front"
	^ (population collect: [ :i | i -> (self distanceFromSolutionOf: i) ]) 
		asSortedCollection: [ :i1 :i2 | i1 value < i2 value ]
	"| d as |
	d := Dictionary new.
	population do: [ :i | d at: i put: (self distanceFromSolutionOf: i) abs].
	as := d associations asSortedCollection: [ :a1 :a2 | a1 value < a2 value ].
	^ as collect: #key"

]

{ #category : #'as yet unclassified' }
GPEngine >> ratioOfDifferentIndividualsIn: setOfIndividuals [
	^ ((self numberOfDifferentIndividualsIn: setOfIndividuals) / setOfIndividuals size) asFloat round: 2
]

{ #category : #'as yet unclassified' }
GPEngine >> sortedIndividuals [
	"return the list of individuals, sorted as the best match in front"
	^ (population collect: [ :i | i -> i fitness ]) 
		asSortedCollection: [ :i1 :i2 | i1 value < i2 value ]

]

{ #category : #evolution }
GPEngine >> tournament [
	"Return the best individual from a tournament"
	| k best ind |
	best := nil.
	k := 2.
	k timesRepeat: [ 
		ind := self randomElementOf: population. "population at: (configuration random randomNumber: population size)".
		(best isNil or: [ ind fitness < best fitness ]) 
			ifTrue: [ best := ind ] ].
	^ best
	"| fitness best |
	best := (population asSortedCollection: [ :ind1 :ind2 | ind1 fitness > ind2 fitness ]) first.
	fitness := best fitness.
	5 timesRepeat: [ 
		| competitor i |
		competitor := configuration randomElementOf: population.
		i := competitor fitness.
		(i < fitness ""or: [i = fitness]"") ifTrue: [ 
			best := competitor.
			fitness := competitor fitness ]
	].
	^ best"
]

{ #category : #evolution }
GPEngine >> tournamentDiscarding: individual [
	"Return the best individual from a tournament"
	| k best ind size i j m |
	best := nil.
	k := 2.
	size := population size.
	m := size > k 
		ifTrue: [ k ]
		ifFalse: [ size - 1 ].
	i := j := 0.
	[ i < m and: [ j < 50 ] ] whileTrue: [ 
		ind := self randomElementOf: population.
		individual = ind ifFalse: [
			i := i + 1.
			(best isNil or: [ ind fitness < best fitness ]) 
				ifTrue: [ best := ind ] ].
		j := j + 1
	].
	best ifNil: [ best := self tournament ].
	^ best
	"k timesRepeat: [ 
		ind := self randomElementOf: population.
		(best isNil or: [ ind fitness < best fitness ]) 
			ifTrue: [ best := ind ] ].
	^ best"
	"| fitness best |
	best := (population asSortedCollection: [ :ind1 :ind2 | ind1 fitness > ind2 fitness ]) first.
	fitness := best fitness.
	5 timesRepeat: [ 
		| competitor i |
		competitor := configuration randomElementOf: population.
		i := competitor fitness.
		(i < fitness ""or: [i = fitness]"") ifTrue: [ 
			best := competitor.
			fitness := competitor fitness ]
	].
	^ best"
]
