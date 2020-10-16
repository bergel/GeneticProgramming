Class {
	#name : #GPASTConfiguration,
	#superclass : #Object,
	#instVars : [
		'rulesWeights',
		'optionsWeights',
		'depth'
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

{ #category : #accessing }
GPASTConfiguration >> depth [

	 ^ depth
]

{ #category : #accessing }
GPASTConfiguration >> depth: number [
	depth := number
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

	^ optionsWeights at: symbol ifAbsent: [ #(1) ]
]

{ #category : #accesing }
GPASTConfiguration >> rulesWeights [

	 ^ rulesWeights
]

{ #category : #accesing }
GPASTConfiguration >> rulesWeightsOf: keys [

	 ^ rulesWeights associations select: [ :assoc | keys includes: assoc key ] thenCollect: [ :assoc | assoc value ]
]
