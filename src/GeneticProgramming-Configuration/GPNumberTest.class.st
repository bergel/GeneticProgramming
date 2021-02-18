Class {
	#name : #GPNumberTest,
	#superclass : #TestCase,
	#instVars : [
		'p'
	],
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #running }
GPNumberTest >> setUp [ 
	p := GPPlay new
]

{ #category : #tests }
GPNumberTest >> test01 [
	self deny: (p m: Object new).
]

{ #category : #tests }
GPNumberTest >> test02 [
	self deny: (p m: 'hello')
]

{ #category : #tests }
GPNumberTest >> test03 [
	self assert: (p m: 3)
]

{ #category : #tests }
GPNumberTest >> test04 [
	self assert: (p m: 9)
]

{ #category : #tests }
GPNumberTest >> test05 [
	self deny: (p m: 2)
]

{ #category : #tests }
GPNumberTest >> test06 [
	self deny: (p m: 4)
]
