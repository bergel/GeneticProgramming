Class {
	#name : #GPPlayTest,
	#superclass : #TestCase,
	#instVars : [
		'p'
	],
	#category : #'GeneticProgramming-Configuration-GPPlay'
}

{ #category : #tests }
GPPlayTest >> setUp [
	p := GPPlay new
]

{ #category : #tests }
GPPlayTest >> test01 [
	self deny: (p m: Object new).
]

{ #category : #tests }
GPPlayTest >> test02 [
	self deny: (p m: 'hello')
]

{ #category : #tests }
GPPlayTest >> test03 [
	self assert: (p m: #('hello' 'world'))
]

{ #category : #tests }
GPPlayTest >> test04 [
	self deny: (p m: #(1 'world'))
]

{ #category : #tests }
GPPlayTest >> test05 [
	self deny: (p m: (Array with: #() with: (Dictionary new)))
]
