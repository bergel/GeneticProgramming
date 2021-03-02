Class {
	#name : #GPRuleOption,
	#superclass : #Object,
	#instVars : [
		'nodes',
		'ruleName',
		'indexes',
		'nodeOptions'
	],
	#category : #'GeneticProgramming-Grammar'
}

{ #category : #adding }
GPRuleOption >> addNode: aNode [
	self addNode: aNode withValueOptions: #()
]

{ #category : #adding }
GPRuleOption >> addNode: aNode withValueOptions: collection [
	nodes add: aNode -> collection.
	indexes add: 'node' -> nodes size.
]

{ #category : #adding }
GPRuleOption >> addNodeOption: anObject [
	nodeOptions add: anObject.
	indexes add: 'nodeOption' -> nodeOptions size.
]

{ #category : #accessing }
GPRuleOption >> addValueOptions: collection at: index [
	(self getValueOptionsAt: index)
		addAll: collection
]

{ #category : #'as yet unclassified' }
GPRuleOption >> allOptions [
	^ indexes collect: [ :assoc | 
		assoc key = 'node' 
			ifTrue: [ assoc key -> (nodes at: assoc value) ]
			ifFalse: [ assoc key -> (nodeOptions at: assoc value) ] ]
]

{ #category : #accessing }
GPRuleOption >> getNodeAt: index [
	^ index <= nodes size 
		ifTrue: [ (nodes at: index) key ] 
		ifFalse: [ nil ]
]

{ #category : #accessing }
GPRuleOption >> getNodeOptionAt: index [
	^ index <= nodeOptions size 
		ifTrue: [ nodeOptions at: index ] 
		ifFalse: [ nil ]
]

{ #category : #accessing }
GPRuleOption >> getNodeWithOptionsAt: index [
	^ index <= nodes size 
		ifTrue: [ nodes at: index ] 
		ifFalse: [ nil ]
	
]

{ #category : #accessing }
GPRuleOption >> getValueOptionsAt: index [
	^ index <= nodes size 
		ifTrue: [ (nodes at: index) value ] 
		ifFalse: [ nil ]
]

{ #category : #initialization }
GPRuleOption >> initialize [
	nodes := OrderedCollection new.
	nodeOptions := OrderedCollection new.
	indexes := OrderedCollection new.
]

{ #category : #accessing }
GPRuleOption >> nodeOptions [
	^ nodeOptions
]

{ #category : #accessing }
GPRuleOption >> nodes [ 
	^ nodes
]

{ #category : #accessing }
GPRuleOption >> replaceValueOptions: collection at: index [
	(self getValueOptionsAt: index) removeAll;
		addAll: collection
]

{ #category : #accessing }
GPRuleOption >> ruleName [

	^ ruleName
]

{ #category : #accessing }
GPRuleOption >> ruleName: anObject [

	ruleName := anObject
]
