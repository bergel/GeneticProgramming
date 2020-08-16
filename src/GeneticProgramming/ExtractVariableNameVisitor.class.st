Class {
	#name : #ExtractVariableNameVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'variableNames',
		'classNames'
	],
	#category : #'GeneticProgramming-CodeGenerator'
}

{ #category : #'to clean later' }
ExtractVariableNameVisitor >> allClasses [ 
	^ Smalltalk allClasses asOrderedCollection 
]

{ #category : #initialization }
ExtractVariableNameVisitor >> classNames [
    ^ classNames
]

{ #category : #initialization }
ExtractVariableNameVisitor >> initialize [ 
    super initialize.
    variableNames := OrderedCollection new.
	 classNames 		:= OrderedCollection new.
]

{ #category : #testing }
ExtractVariableNameVisitor >> isClass: aClassSymbol [

	^(self allClasses) includes:
					(OpalCompiler new
						source: aClassSymbol; evaluate)	
]

{ #category : #initialization }
ExtractVariableNameVisitor >> variableNames [
    ^ variableNames removeDuplicates 
]

{ #category : #initialization }
ExtractVariableNameVisitor >> visitVariableNode: aVariableNode [
	|n|
	n := aVariableNode  name.
	(self isClass: n)
	ifTrue: [ classNames add: n]
	ifFalse: [ variableNames  add: n].
   ^ aVariableNode
]
