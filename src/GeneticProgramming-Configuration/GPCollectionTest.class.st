Class {
	#name : #GPCollectionTest,
	#superclass : #TestCase,
	#instVars : [
		'p'
	],
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #running }
GPCollectionTest >> setUp [ 
	p := GPPlay new
]

{ #category : #tests }
GPCollectionTest >> test01 [
	self deny: (p m: Object new)
]

{ #category : #tests }
GPCollectionTest >> test02 [
	self deny: (p m: 'hello')
]

{ #category : #tests }
GPCollectionTest >> test03 [
	self assert: (p m: #(1 4 3 5 7))
]

{ #category : #tests }
GPCollectionTest >> test04 [
	self deny: (p m: #(1 3 5 7))
]

{ #category : #tests }
GPCollectionTest >> test05 [
	self deny: (p m: #('hello' 'world'))
]

{ #category : #tests }
GPCollectionTest >> test06 [
	self deny: (p m: 2)
]

{ #category : #tests }
GPCollectionTest >> test07 [
	self deny: (p m: 4)
]
