Class {
	#name : #GPASTConfiguration,
	#superclass : #Object,
	#instVars : [
		'rulesWeights',
		'optionsWeights'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #adding }
GPASTConfiguration >> addOptionWeights: numbers forRule: symbol [

	 optionsWeights at: symbol put: numbers
]

{ #category : #adding }
GPASTConfiguration >> addWeight: number forRule: symbol [

	 rulesWeights at: symbol put: number
]

{ #category : #initialization }
GPASTConfiguration >> initialize [ 	
	rulesWeights := Dictionary new.
	optionsWeights := Dictionary new
]

{ #category : #accesing }
GPASTConfiguration >> keysOfRuleWeights [ 
	^ rulesWeights keys
]

{ #category : #accesing }
GPASTConfiguration >> optionWeightsOf: symbol [

	 ^ optionsWeights at: symbol 
]

{ #category : #accesing }
GPASTConfiguration >> rulesWeights [

	 ^ rulesWeights
]
