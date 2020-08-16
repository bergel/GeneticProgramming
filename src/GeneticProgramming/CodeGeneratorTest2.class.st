Class {
	#name : #CodeGeneratorTest2,
	#superclass : #TestCase,
	#instVars : [
		'c',
		'd'
	],
	#category : #'GeneticProgramming-CodeGenerator'
}

{ #category : #running }
CodeGeneratorTest2 >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	| x y|
	x := -10 to: 10 by: 2.
	y := x.
	c := RSChart new.
	d := RSLinePlot new.
	d x: x y: y.
	


]

{ #category : #tests }
CodeGeneratorTest2 >> testBasic01 [
	self assert: d maxValueY equals: 10.
]

{ #category : #tests }
CodeGeneratorTest2 >> testBasic02 [
	c addPlot: d.
	self assert: c maxValueY equals: 10.
]
