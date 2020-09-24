Class {
	#name : #GPBlock,
	#superclass : #Object,
	#instVars : [
		'exprs'
	],
	#category : #'GeneticProgramming-AST'
}

{ #category : #adding }
GPBlock >> addExpr: expression [
	exprs add: expression 
]

{ #category : #copying }
GPBlock >> deepCopy [
	^ self class new 
		exprs: (self exprs collect: #deepCopy) 
]

{ #category : #'public access' }
GPBlock >> evaluate [ 
	^ (exprs collect: #evaluate) last
	
]

{ #category : #accessing }
GPBlock >> exprs [
	^ exprs
]

{ #category : #accessing }
GPBlock >> exprs: anObject [
	exprs := anObject
]

{ #category : #initialization }
GPBlock >> initialize [ 
	exprs := OrderedCollection new
]

{ #category : #operations }
GPBlock >> mutate [ 
	| index random |
	random := Random seed: 42.
	index := random nextInt: exprs size. 
	^ self deepCopy exprs at: index put: (exprs at: index) mutate
]

{ #category : #printing }
GPBlock >> printOn: stream [
	stream nextPut: $[.
	exprs do: [ :expr | expr printOn: stream ].
	stream nextPut: $]
]